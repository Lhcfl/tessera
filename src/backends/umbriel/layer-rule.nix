{ config, lib, ... }:
let
  cfg = config.tessera.settings;

  umbrielApplyKeys = [
    "blur"
    "blur_popups"
    "blur_ignore_alpha"
    "blur_optimized"
  ];

  umbrielMatchKeys = [
    "namespace"
    "layer"
    "at_startup"
  ];

  stripNulls =
    value:
    if lib.isAttrs value then
      lib.filterAttrs (_: item: item != null) (lib.mapAttrs (_: stripNulls) value)
    else if lib.isList value then
      map stripNulls value
    else
      value;

  filterApply =
    rule:
    lib.mapAttrs (_: stripNulls) (
      lib.filterAttrs (name: value: value != null && builtins.elem name umbrielApplyKeys) rule
    );

  filterMatch =
    block: lib.filterAttrs (name: value: value != null && builtins.elem name umbrielMatchKeys) block;

  hasSelectors = block: lib.any (value: value != null) (lib.attrValues block);

  filterMatchRule =
    rule:
    if rule.match == null || !hasSelectors rule.match then
      rule // { match = null; }
    else
      rule // { match = filterMatch rule.match; };

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

  mkRule =
    { order, ... }@rule:
    {
      inherit order;
      body = removeAttrs rule [ "order" ];
    };
in
{
  config.tessera.umbriel.settings.layer_rule = lib.pipe cfg.layer-rule [
    (lib.mapAttrsToList (_: rule: rule))

    # Normalize `match` to a list, using null as the "match all" sentinel.
    (map normalizeMatch)

    # Expand match blocks into separate rules.
    (map (rule: map (match: rule // { match = match; }) rule.match))
    lib.concatLists

    # Filter unsupported match selectors, then drop rules that can never match
    # because none of their selectors are supported by the backend.
    (map filterMatchRule)
    (builtins.filter (rule: rule.match != { }))

    # Keep only supported apply fields, then drop rules with nothing left to apply.
    (map (rule: filterApply rule // { inherit (rule) order match; }))
    (builtins.filter (
      rule:
      removeAttrs rule [
        "order"
        "match"
      ] != { }
    ))

    # Omit the null match sentinel from the TOML output.
    (map (rule: if rule.match == null then removeAttrs rule [ "match" ] else rule))

    (map mkRule)
    (map ({ order, body }: order [ body ]))
    lib.mkMerge
  ];
}
