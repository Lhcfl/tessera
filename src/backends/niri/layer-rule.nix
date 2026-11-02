{
  pkgs,
  nix-kdl,
  config,
  lib,
  ...
}:
let
  cfg = config.tessera.settings;

  inherit
    (import ../../lib {
      inherit lib pkgs;
      name = "niri";
    })
    match
    ;

  inherit (nix-kdl) kdl;
  inherit (kdl.extras) niri;
  inherit (niri) n raw;

  niriMatchMap = {
    namespace = "namespace";
    layer = "layer";
    at_startup = "at-startup";
  };

  niriApplyKeys = [
    "blur"
    "blur_popups"
    "blur_optimized"
    "opacity"
    "block_capture"
    "shadow"
    "geometry_corner_radius"
    "place_within_backdrop"
    "baba_is_float"
    "background_effect"
    "popups"
  ];

  nonNull = lib.filterAttrs (_: value: value != null);

  node = name: value: lib.optional (value != null) (n name value);

  multiNode =
    name: value:
    if lib.isList value then builtins.foldl' (acc: item: acc item) (n name) value else n name value;

  propsNode =
    name: props:
    let
      filtered = nonNull props;
    in
    lib.optional (filtered != { }) (n name filtered);

  bodyNode =
    name: body:
    let
      filtered = lib.filter (item: item != null) (lib.flatten body);
    in
    lib.optional (filtered != [ ]) (n name filtered);

  backgroundEffectFields =
    effect:
    lib.flatten [
      (node "noise" effect.noise)
      (node "saturation" effect.saturation)
    ];

  backgroundEffectNode =
    rule:
    bodyNode "background-effect" (
      lib.flatten [
        (node "blur" rule.blur)
        (node "xray" rule.blur_optimized)
        (if rule.background_effect == null then [ ] else backgroundEffectFields rule.background_effect)
      ]
    );

  shadowBody =
    shadow:
    lib.flatten [
      (lib.optional (shadow.on == true) (n "on"))
      (lib.optional (shadow.off == true) (n "off"))
      (node "softness" shadow.softness)
      (node "spread" shadow.spread)
      (
        if shadow.offset == null then
          [ ]
        else
          propsNode "offset" {
            inherit (shadow.offset) x y;
          }
      )
      (node "draw-behind-window" shadow.draw_behind_window)
      (node "color" shadow.color)
      (node "inactive-color" shadow.inactive_color)
    ];

  shadowNode = rule: if rule.shadow == null then [ ] else bodyNode "shadow" (shadowBody rule.shadow);

  popupsNode =
    rule:
    let
      popups = rule.popups;
      popupEffect = if popups == null then null else popups.background_effect;
      effectBody = lib.flatten [
        (if popupEffect == null then [ ] else backgroundEffectFields popupEffect)
        (node "blur" rule.blur_popups)
        (node "xray" rule.blur_optimized)
      ];
      body = lib.flatten [
        (if popups == null then [ ] else node "opacity" popups.opacity)
        (
          if popups == null then
            [ ]
          else
            lib.optional (popups.geometry_corner_radius != null) (
              multiNode "geometry-corner-radius" popups.geometry_corner_radius
            )
        )
        (lib.optional (effectBody != [ ]) (n "background-effect" effectBody))
      ];
    in
    if body == [ ] then [ ] else bodyNode "popups" body;

  ruleApplyNodes =
    rule:
    lib.flatten [
      (node "opacity" rule.opacity)
      (lib.optional (rule.block_capture == true) (n "block-out-from" "screen-capture"))
      (shadowNode rule)
      (node "geometry-corner-radius" rule.geometry_corner_radius)
      (node "place-within-backdrop" rule.place_within_backdrop)
      (node "baba-is-float" rule.baba_is_float)
      (backgroundEffectNode rule)
      (popupsNode rule)
    ];

  mapMatch =
    block:
    lib.mapAttrs' (name: value: lib.nameValuePair niriMatchMap.${name} value) (
      lib.filterAttrs (name: value: value != null && builtins.hasAttr name niriMatchMap) block
    );

  hasSelectors = block: lib.any (value: value != null) (lib.attrValues block);

  filterMatchRule =
    rule:
    if rule.match == null || !hasSelectors rule.match then
      rule // { match = null; }
    else
      rule // { match = mapMatch rule.match; };

  normalizeMatch =
    rule:
    rule
    // {
      match =
        if rule.match == null then
          [ null ]
        else if lib.isList rule.match then
          rule.match
        else
          [ rule.match ];
    };

  filterApplyFields =
    rule: lib.filterAttrs (name: value: value != null && builtins.elem name niriApplyKeys) rule;

  mkRule =
    { name, order, ... }@rule:
    {
      inherit name order;
      body = removeAttrs rule [
        "name"
        "order"
      ];
    };

  priorityOf =
    { order, ... }:
    let
      ordered = order [ ];
    in
    if lib.isAttrs ordered && (ordered._type or null) == "order" then ordered.priority else 1000;

  renderRule =
    { name, body, ... }:
    lib.flatten [
      (raw "// ${name}")
      (n "layer-rule" (
        lib.flatten [
          (if (body.match or null) == null then [ ] else [ (n "match" body.match) ])
          (ruleApplyNodes body)
        ]
      ))
    ];
in
lib.pipe cfg.layer-rule [
  (lib.mapAttrsToList (name: rule: rule // { inherit name; }))

  # Normalize `match` to a list, using null as the "match all" sentinel.
  (map normalizeMatch)

  # Expand match blocks into separate rules.
  (map (rule: map (match: rule // { match = match; }) rule.match))
  lib.concatLists

  # Translate supported selectors, then drop rules that can never match because
  # none of their selectors are supported by the backend.
  (map filterMatchRule)
  (builtins.filter (rule: rule.match != { }))

  # Drop rules with no supported apply fields.
  (builtins.filter (rule: filterApplyFields rule != { }))

  # Omit the null match sentinel from the rendered rule body.
  (map (rule: if rule.match == null then removeAttrs rule [ "match" ] else rule))

  (map mkRule)
  (lib.sort (a: b: priorityOf a < priorityOf b || (priorityOf a == priorityOf b && a.name < b.name)))
  (lib.concatMap renderRule)
]
