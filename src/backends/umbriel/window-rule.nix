{ config, lib, ... }:
let
  cfg = config.tessera.settings;

  umbrielApplyKeys = [
    "default_output"
    "default_workspace"
    "default_scratchpad"
    "default_fullscreen"
    "default_floating"
    "default_maximize"
    "default_maximize_to_edges"
    "default_focused"
    "default_pinned"
    "default_scrolling_column"
    "default_scrolling_column_order"
    "default_column_display"
    "default_floating_size_px"
    "default_floating_size"
    "default_scrolling_extent_px"
    "default_scrolling_extent"
    "default_position"
    "attach_to_parent"
    "opacity"
    "blur"
    "blur_popups"
    "blur_ignore_alpha"
    "blur_optimized"
    "confine_pointer"
    "allow_shortcuts_inhibit"
    "block_capture"
    "background_render"
    "focus_on_activate"
    "vrr"
    "tearing"
    "hdr"
    "border_color_focused"
    "border_color_unfocused"
    "border_color_outer"
    "border_width"
    "outer_border_width"
    "corner_radius"
    "shadow"
    "title_bar"
    "title_bar_buttons"
    "border_effect"
    "window_effect"
  ];

  umbrielMatchKeys = [
    "app_id"
    "title"
    "xdg_tag"
    "content_type"
    "is_focused"
    "is_floating"
    "is_maximized_to_edges"
    "is_pinned"
    "is_scratchpad"
    "is_alone"
    "is_only_window"
    "is_dialog"
    "is_cast_target"
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

  hasSelectors = block: lib.any (value: value != null) (lib.attrValues block);

  filterMatchRule =
    rule:
    if rule.match == null || !hasSelectors rule.match then
      rule // { match = null; }
    else
      rule // { match = filterMatch rule.match; };

  mkRule =
    { order, ... }@rule:
    {
      inherit order;
      body = removeAttrs rule [ "order" ];
    };

in
{
  config.tessera.umbriel.settings.window_rule = lib.pipe cfg.window-rule [
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
