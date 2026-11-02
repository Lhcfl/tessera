margs@{
  pkgs,
  nix-kdl,
  config,
  lib,
  ...
}:
let
  cfg = config.tessera.settings;
  niri-cfg = config.tessera.niri;

  inherit (nix-kdl) kdl;
  inherit (kdl.extras) niri;
  inherit (niri) n raw;

  inherit
    (import ../../lib {
      inherit lib pkgs;
      name = "niri";
    })
    mkProvideContextOptions
    mkDestination
    mkIncludes
    percentage
    ;

  rmap = lib.flip map;

  nonNull = lib.filterAttrs (_: value: value != null);

  node = name: value: lib.optional (value != null) (n name value);

  flag = condition: name: lib.optional (condition == true) (n name);

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
      let
        props = nonNull {
          from = gradient.from;
          to = gradient.to;
          angle = gradient.angle;
          "in" = gradient."in";
          relative-to = gradient.relative_to;
        };
      in
      lib.optional (props != { }) (n name props);

  ringBody =
    ring:
    lib.flatten [
      (flag ring.on "on")
      (flag ring.off "off")
      (node "width" ring.width)
      (node "active-color" ring.active_color)
      (node "inactive-color" ring.inactive_color)
      (node "urgent-color" ring.urgent_color)
      (gradientNode "active-gradient" ring.active_gradient)
      (gradientNode "inactive-gradient" ring.inactive_gradient)
      (gradientNode "urgent-gradient" ring.urgent_gradient)
    ];

  ringNode = name: ring: if ring == null then [ ] else bodyNode name (ringBody ring);

  touchpadBody =
    touchpad:
    lib.flatten [
      (flag touchpad.tap "tap")
      (flag touchpad.natural_scroll "natural-scroll")
      (flag touchpad.left_handed "left-handed")
      (node "accel-profile" touchpad.accel_profile)
      (node "accel-speed" touchpad.sensitivity)
      (node "scroll-factor" touchpad.scroll_factor)
      (flag touchpad.disable_while_typing "dwt")
      (flag touchpad.disable_on_external_mouse "disabled-on-external-mouse")
      (node "click-method" touchpad.click_method)
      (node "tap-button-map" (
        if touchpad.tap_button_map == null then
          null
        else
          lib.replaceStrings [ "_" ] [ "-" ] touchpad.tap_button_map
      ))
    ];

  blurBody = lib.flatten [
    (flag (cfg.appearance.blur.enabled == false) "off")
    (node "passes" cfg.appearance.blur.passes)
    (node "offset" cfg.appearance.blur.offset)
    (node "noise" cfg.appearance.blur.noise)
    (node "saturation" cfg.appearance.blur.saturation)
  ];

  borderBody = lib.flatten [
    (flag cfg.layout.border.on "on")
    (flag cfg.layout.border.off "off")
    (node "width" cfg.appearance.border_width)
    (node "active-color" cfg.colors.border.focused)
    (node "inactive-color" cfg.colors.border.unfocused)
    (node "urgent-color" cfg.layout.border.urgent_color)
    (gradientNode "active-gradient" cfg.layout.border.active_gradient)
    (gradientNode "inactive-gradient" cfg.layout.border.inactive_gradient)
    (gradientNode "urgent-gradient" cfg.layout.border.urgent_gradient)
  ];

  outputNode =
    name: output:
    n "output" name (
      lib.flatten [
        (lib.optional (output.enabled == false) (n "off"))
        (node "mode" output.mode)
        (node "scale" output.scale)
        (node "transform" output.transform)
        (
          if output.vrr == null || output.vrr == "disabled" then
            [ ]
          else if output.vrr == "always" then
            n "variable-refresh-rate"
          else
            n "variable-refresh-rate" { on-demand = true; }
        )
        (
          if output.position == null then
            [ ]
          else
            propsNode "position" {
              inherit (output.position) x y;
            }
        )
      ]
    );

  propsNode =
    name: props:
    let
      filtered = nonNull props;
    in
    lib.optional (filtered != { }) (n name filtered);
in
{
  options.tessera.niri = {
    enable = lib.mkEnableOption "unified compositor settings for niri";
    provide = mkProvideContextOptions;
    out = mkDestination;
    includes = mkIncludes;

  };

  config.tessera.niri = {
    provide = {
      workspace.empty.id = 255;
    };

    out.target = ".config/niri/config.kdl";
    out.text = kdl.formats.v1 (
      lib.flatten [
        (rmap cfg.general.autostart (n "spawn-sh-at-startup"))
        (lib.optional (cfg.appearance.prefer_no_csd == true) (n "prefer-no-csd"))
        (node "screenshot-path" cfg.screenshot.path)
        (bodyNode "cursor" [
          (node "xcursor-theme" cfg.input.cursor.theme)
          (node "xcursor-size" cfg.input.cursor.size)
          (flag cfg.input.cursor.hide_when_typing "hide-when-typing")
          (node "hide-after-inactive-ms" cfg.input.cursor.hide_timeout_ms)
        ])
        (bodyNode "hotkey-overlay" [
          (flag cfg.hotkey_overlay.hide_not_bound "hide-not-bound")
          (flag cfg.hotkey_overlay.skip_at_startup "skip-at-startup")
        ])
        (bodyNode "blur" blurBody)
        (bodyNode "overview" [
          (
            if cfg.overview.workspace_shadow == null then
              [ ]
            else
              bodyNode "workspace-shadow" [
                (n (if cfg.overview.workspace_shadow then "on" else "off"))
              ]
          )
        ])
        (lib.mkIf (cfg.environment != { }) (
          n "environment" (lib.mapAttrsToList (name: value: n name value) cfg.environment)
        ))
        (n "input" (
          lib.flatten [
            (raw "// input settings")
            (lib.mkIf cfg.input.follow-mouse (
              n "focus-follows-mouse" {
                max-scroll-amount = percentage cfg.input.follow-mouse-max-scroll;
              }
            ))
            (flag cfg.input.mouse-follows-focus "warp-mouse-to-focus")
            (bodyNode "touchpad" (touchpadBody cfg.input.touchpad))
          ]
        ))
        (n "binds" (import ./keybinds.nix margs))
        (n "layout" (
          lib.flatten [
            (node "gaps" cfg.layout.gap)
            (bodyNode "struts" [
              (node "left" cfg.layout.struts.left)
              (node "right" cfg.layout.struts.right)
              (node "top" cfg.layout.struts.top)
              (node "bottom" cfg.layout.struts.bottom)
            ])
            (node "background-color" cfg.layout.background_color)
            (node "center-focused-column" (
              if cfg.layout.scrolling.center_focused == null then
                null
              else
                lib.replaceStrings [ "_" ] [ "-" ] cfg.layout.scrolling.center_focused
            ))
            (
              if cfg.layout.scrolling.default_extent_fraction == null then
                [ ]
              else
                n "default-column-width" [
                  (n "proportion" cfg.layout.scrolling.default_extent_fraction)
                ]
            )
            (n "preset-column-widths" (map (n "proportion") cfg.layout.preset-column-widths))
            (ringNode "focus-ring" cfg.layout.focus_ring)
            (bodyNode "border" borderBody)
          ]
        ))
        (lib.mapAttrsToList outputNode cfg.outputs)
        (import ./window-rule.nix margs)
        (import ./layer-rule.nix margs)
        (rmap niri-cfg.includes (item: n "include" { optional = item.optional; } item.source))
      ]
    );
  };
}
