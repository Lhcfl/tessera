{ lib, ... }:
let
  inherit
    (import ../lib {
      inherit lib;
      pkgs = null;
      name = "options";
    })
    mkOption
    mkNullableOption
    ;
  t = lib.types;

  gradient = t.submodule {
    options = {
      from = mkNullableOption {
        applies = [ "niri" ];
        type = t.str;
        description = "Start color.";
      };
      to = mkNullableOption {
        applies = [ "niri" ];
        type = t.str;
        description = "End color.";
      };
      angle = mkNullableOption {
        applies = [ "niri" ];
        type = t.number;
        description = "CSS-like angle in degrees; defaults to 180.";
      };
      "in" = mkNullableOption {
        applies = [ "niri" ];
        type = t.str;
        description = ''Gradient interpolation color space, such as "srgb-linear" or "oklch longer hue".'';
      };
      relative_to = mkNullableOption {
        applies = [ "niri" ];
        type = t.enum [
          "window"
          "workspace-view"
        ];
        description = "Render the gradient relative to the window or to the whole workspace view.";
      };
    };
  };

  ring = t.submodule {
    options = {
      on = mkNullableOption {
        applies = [ "niri" ];
        type = t.bool;
        description = "Force-enable this element.";
      };
      off = mkNullableOption {
        applies = [ "niri" ];
        type = t.bool;
        description = "Disable this element. `on` takes precedence.";
      };
      width = mkNullableOption {
        applies = [ "niri" ];
        type = t.number;
        description = "Thickness in logical pixels.";
      };
      active_color = mkNullableOption {
        applies = [ "niri" ];
        type = t.str;
        description = "Color for the active window.";
      };
      inactive_color = mkNullableOption {
        applies = [ "niri" ];
        type = t.str;
        description = "Color for other windows.";
      };
      urgent_color = mkNullableOption {
        applies = [ "niri" ];
        type = t.str;
        description = "Color for windows requesting attention.";
      };
      active_gradient = mkNullableOption {
        applies = [ "niri" ];
        type = gradient;
        description = "Gradient for the active window.";
      };
      inactive_gradient = mkNullableOption {
        applies = [ "niri" ];
        type = gradient;
        description = "Gradient for other windows.";
      };
      urgent_gradient = mkNullableOption {
        applies = [ "niri" ];
        type = gradient;
        description = "Gradient for windows requesting attention.";
      };
    };
  };
in
{
  options.tessera.settings.layout = {
    preset-column-widths = mkOption {
      applies = [
        "niri"
        "umbriel"
      ];
      type = t.listOf t.number;
      default = [
        0.333
        0.5
        0.667
      ];
      description = "Fractions used by `resize-preset` actions.";
    };

    gap = mkNullableOption {
      applies = [
        "niri"
        "umbriel"
      ];
      type = t.number;
      description = "Gap between windows in logical pixels.";
    };

    struts = mkOption {
      applies = [
        "niri"
        "umbriel"
      ];
      default = { };
      description = "Reserve or reclaim space at the edges of the layout.";
      type = t.submodule {
        options = {
          left = mkNullableOption {
            applies = [
              "niri"
              "umbriel"
            ];
            type = t.number;
            description = "Left strut in logical pixels.";
          };
          right = mkNullableOption {
            applies = [
              "niri"
              "umbriel"
            ];
            type = t.number;
            description = "Right strut in logical pixels.";
          };
          top = mkNullableOption {
            applies = [
              "niri"
              "umbriel"
            ];
            type = t.number;
            description = "Top strut in logical pixels.";
          };
          bottom = mkNullableOption {
            applies = [
              "niri"
              "umbriel"
            ];
            type = t.number;
            description = "Bottom strut in logical pixels.";
          };
        };
      };
    };

    background_color = mkNullableOption {
      applies = [ "niri" ];
      type = t.str;
      description = "Layout background color.";
    };

    scrolling = mkOption {
      applies = [
        "niri"
        "umbriel"
      ];
      default = { };
      description = "Scrolling layout settings.";
      type = t.submodule {
        options = {
          default_extent_fraction = mkNullableOption {
            applies = [
              "niri"
              "umbriel"
            ];
            type = t.float;
            description = "Initial column extent from 0.1 to 4.0.";
          };
          center_underfull_strip = mkNullableOption {
            applies = [ "umbriel" ];
            type = t.bool;
            description = "Center a strip narrower than the viewport.";
          };
          center_focused = mkNullableOption {
            applies = [
              "niri"
              "umbriel"
            ];
            type = t.enum [
              "never"
              "always"
              "on_overflow"
            ];
            description = "When to center the focused column.";
          };
          center_on_overview_select = mkNullableOption {
            applies = [ "umbriel" ];
            type = t.bool;
            description = "Center the column picked in the overview on close.";
          };
        };
      };
    };

    focus_ring = mkNullableOption {
      applies = [ "niri" ];
      type = ring;
      description = "Niri focus-ring options.";
    };

    border = mkOption {
      applies = [ "niri" ];
      default = { };
      description = "Niri-specific border gradient options. Width and colors use appearance and colors.";
      type = t.submodule {
        options = {
          on = mkNullableOption {
            applies = [ "niri" ];
            type = t.bool;
            description = "Force-enable the border.";
          };
          off = mkNullableOption {
            applies = [ "niri" ];
            type = t.bool;
            description = "Disable the border.";
          };
          urgent_color = mkNullableOption {
            applies = [ "niri" ];
            type = t.str;
            description = "Color for windows requesting attention.";
          };
          active_gradient = mkNullableOption {
            applies = [ "niri" ];
            type = gradient;
            description = "Gradient for the active window.";
          };
          inactive_gradient = mkNullableOption {
            applies = [ "niri" ];
            type = gradient;
            description = "Gradient for other windows.";
          };
          urgent_gradient = mkNullableOption {
            applies = [ "niri" ];
            type = gradient;
            description = "Gradient for windows requesting attention.";
          };
        };
      };
    };
  };
}
