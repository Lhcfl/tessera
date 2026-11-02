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
    app_id = "app-id";
    title = "title";
    is_focused = "is-focused";
    is_urgent = "is-urgent";
    is_floating = "is-floating";
    is_cast_target = "is-window-cast-target";
    at_startup = "at-startup";
  };

  niriApplyKeys = [
    "default_output"
    "default_workspace"
    "default_fullscreen"
    "default_floating"
    "default_maximize"
    "default_maximize_to_edges"
    "default_focused"
    "default_column_display"
    "default_scrolling_extent"
    "default_scrolling_extent_px"
    "default_window_height"
    "default_position"
    "opacity"
    "blur"
    "blur_popups"
    "blur_optimized"
    "block_capture"
    "focus_on_activate"
    "vrr"
    "border_color_focused"
    "border_color_unfocused"
    "border_width"
    "corner_radius"
    "shadow"
    "scroll_factor"
    "pinch_sensitivity"
    "draw_border_with_background"
    "focus_ring"
    "tab_indicator"
    "clip_to_geometry"
    "tiled_state"
    "popups"
    "min_width"
    "max_width"
    "min_height"
    "max_height"
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

  gradientNode =
    name: gradient:
    if gradient == null then
      [ ]
    else
      propsNode name {
        from = gradient.from;
        to = gradient.to;
        angle = gradient.angle;
        "in" = gradient."in";
        relative-to = gradient.relative_to;
      };

  ringBody =
    ring:
    lib.flatten [
      (lib.optional (ring.on == true) (n "on"))
      (lib.optional (ring.off == true) (n "off"))
      (node "width" ring.width)
      (node "active-color" ring.active_color)
      (node "inactive-color" ring.inactive_color)
      (node "urgent-color" ring.urgent_color)
      (gradientNode "active-gradient" ring.active_gradient)
      (gradientNode "inactive-gradient" ring.inactive_gradient)
      (gradientNode "urgent-gradient" ring.urgent_gradient)
    ];

  ringNode = name: ring: if ring == null then [ ] else bodyNode name (ringBody ring);

  backgroundEffectBody =
    effect:
    lib.flatten [
      (node "blur" (effect.blur or null))
      (node "xray" (effect.xray or null))
      (node "noise" (effect.noise or null))
      (node "saturation" (effect.saturation or null))
    ];

  backgroundEffectNode =
    name: effect: if effect == null then [ ] else bodyNode name (backgroundEffectBody effect);

  columnSizeBody =
    size:
    lib.flatten [
      (node "fixed" size.fixed)
      (node "proportion" size.proportion)
    ];

  columnSizeNode = name: size: if size == null then [ ] else bodyNode name (columnSizeBody size);

  positionNode =
    position:
    if position == null then
      [ ]
    else
      propsNode "default-floating-position" {
        x = position.x;
        y = position.y;
        relative-to =
          if position.anchor == null || position.anchor == "center" then
            null
          else
            lib.replaceStrings [ "_" ] [ "-" ] position.anchor;
      };

  tabIndicatorBody =
    indicator:
    let
      length = indicator.length;
    in
    lib.flatten [
      (lib.optional (indicator.on == true) (n "on"))
      (lib.optional (indicator.off == true) (n "off"))
      (lib.optional (indicator.hide_when_single_tab == true) (n "hide-when-single-tab"))
      (lib.optional (indicator.place_within_column == true) (n "place-within-column"))
      (node "gap" indicator.gap)
      (node "width" indicator.width)
      (propsNode "length" {
        total-proportion = if length == null then null else length.total_proportion;
      })
      (node "position" indicator.position)
      (node "gaps-between-tabs" indicator.gaps_between_tabs)
      (node "corner-radius" indicator.corner_radius)
      (node "active-color" indicator.active_color)
      (node "inactive-color" indicator.inactive_color)
      (node "urgent-color" indicator.urgent_color)
      (gradientNode "active-gradient" indicator.active_gradient)
      (gradientNode "inactive-gradient" indicator.inactive_gradient)
      (gradientNode "urgent-gradient" indicator.urgent_gradient)
    ];

  tabIndicatorNode =
    indicator: if indicator == null then [ ] else bodyNode "tab-indicator" (tabIndicatorBody indicator);

  popupsNode =
    rule:
    let
      popups = rule.popups;
      effect = if popups == null then null else popups.background_effect;
      effectBody = lib.flatten [
        (node "blur" rule.blur_popups)
        (node "xray" rule.blur_optimized)
        (if effect == null then [ ] else backgroundEffectBody effect)
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
      (node "open-on-output" rule.default_output)
      (node "open-on-workspace" (
        if rule.default_workspace == null then
          null
        else if lib.isString rule.default_workspace then
          rule.default_workspace
        else
          toString rule.default_workspace
      ))
      (node "open-fullscreen" rule.default_fullscreen)
      (node "open-floating" rule.default_floating)
      (node "open-maximized" rule.default_maximize)
      (node "open-maximized-to-edges" rule.default_maximize_to_edges)
      (node "open-focused" rule.default_focused)
      (node "default-column-display" rule.default_column_display)

      (
        if rule.default_scrolling_extent_px != null then
          n "default-column-width" [ (n "fixed" rule.default_scrolling_extent_px) ]
        else if rule.default_scrolling_extent != null then
          n "default-column-width" [ (n "proportion" rule.default_scrolling_extent) ]
        else
          [ ]
      )
      (columnSizeNode "default-window-height" rule.default_window_height)
      (positionNode rule.default_position)

      (node "opacity" rule.opacity)
      (backgroundEffectNode "background-effect" (
        if rule.blur == null && rule.blur_optimized == null then
          null
        else
          {
            blur = rule.blur;
            xray = rule.blur_optimized;
          }
      ))
      (lib.optional (rule.block_capture == true) (n "block-out-from" "screen-capture"))
      (lib.optional (rule.focus_on_activate != null) (
        n "on-xdg-activate" (if rule.focus_on_activate then "focus" else "set-urgent")
      ))
      (lib.optional (rule.vrr != null) (
        n "variable-refresh-rate" (
          match rule.vrr {
            disabled = false;
            always = true;
            fullscreen = "fullscreen-only";
          }
        )
      ))

      (node "geometry-corner-radius" rule.corner_radius)
      (lib.optional (rule.shadow != null) (n "shadow" [ (n (if rule.shadow then "on" else "off")) ]))

      (node "scroll-factor" rule.scroll_factor)
      (node "pinch-sensitivity" rule.pinch_sensitivity)
      (node "draw-border-with-background" rule.draw_border_with_background)
      (ringNode "focus-ring" rule.focus_ring)
      (tabIndicatorNode rule.tab_indicator)
      (node "clip-to-geometry" rule.clip_to_geometry)
      (node "tiled-state" rule.tiled_state)
      (popupsNode rule)
      (node "min-width" rule.min_width)
      (node "max-width" rule.max_width)
      (node "min-height" rule.min_height)
      (node "max-height" rule.max_height)
    ];

  borderNode =
    rule:
    let
      body = lib.flatten [
        (node "width" rule.border_width)
        (node "active-color" rule.border_color_focused)
        (node "inactive-color" rule.border_color_unfocused)
      ];
    in
    bodyNode "border" body;

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

  renderRule =
    { name, body, ... }:
    lib.flatten [
      (raw "// ${name}")
      (n "window-rule" (
        lib.flatten [
          (if (body.match or null) == null then [ ] else [ (n "match" body.match) ])
          (ruleApplyNodes body)
          (borderNode body)
        ]
      ))
    ];
  priorityOf =
    { order, ... }:
    let
      ordered = order [ ];
    in
    if lib.isAttrs ordered && (ordered._type or null) == "order" then ordered.priority else 1000;
in
lib.pipe cfg.window-rule [
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
