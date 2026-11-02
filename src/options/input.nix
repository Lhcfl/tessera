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
in
{
  options.tessera.settings.input = {
    follow-mouse = mkOption {
      applies = [
        "niri"
        "umbriel"
      ];
      type = t.bool;
      default = false;
      description = "Focus the window under the mouse pointer.";
    };

    follow-mouse-max-scroll = mkOption {
      applies = [
        "niri"
        "umbriel"
      ];
      type = t.float;
      default = 0.5;
      description = ''
        Refuse focus-follows-mouse when focusing would scroll the view
        farther than this many viewport widths.
      '';
    };

    mouse-follows-focus = mkOption {
      applies = [
        "niri"
        "umbriel"
      ];
      type = t.bool;
      default = false;
      description = "Move the cursor to a newly focused window after keyboard-driven focus and transfer actions.";
    };

    touchpad = mkOption {
      applies = [
        "niri"
        "umbriel"
      ];
      default = { };
      description = "Touchpad settings.";
      type = t.submodule {
        options = {
          enabled = mkNullableOption {
            applies = [
              "niri"
              "umbriel"
            ];
            type = t.bool;
            description = "Enable or disable touchpad input.";
          };
          tap = mkNullableOption {
            applies = [
              "niri"
              "umbriel"
            ];
            type = t.bool;
            description = "Enable tap-to-click.";
          };
          natural_scroll = mkNullableOption {
            applies = [
              "niri"
              "umbriel"
            ];
            type = t.bool;
            description = "Reverse scrolling and gesture direction.";
          };
          left_handed = mkNullableOption {
            applies = [
              "niri"
              "umbriel"
            ];
            type = t.bool;
            description = "Swap the primary and secondary buttons.";
          };
          accel_profile = mkNullableOption {
            applies = [
              "niri"
              "umbriel"
            ];
            type = t.str;
            description = ''Use "flat", "adaptive", or a custom acceleration curve.'';
          };
          sensitivity = mkNullableOption {
            applies = [
              "niri"
              "umbriel"
            ];
            type = t.float;
            description = "Pointer speed from -1.0 to 1.0.";
          };
          scroll_factor = mkNullableOption {
            applies = [
              "niri"
              "umbriel"
            ];
            type = t.float;
            description = "Application scroll multiplier from 0.1 to 10.0.";
          };
          disable_while_typing = mkNullableOption {
            applies = [
              "niri"
              "umbriel"
            ];
            type = t.bool;
            description = "Disable the touchpad during keyboard input.";
          };
          disable_on_external_mouse = mkNullableOption {
            applies = [
              "niri"
              "umbriel"
            ];
            type = t.bool;
            description = "Disable the touchpad while an external mouse is connected.";
          };
          click_method = mkNullableOption {
            applies = [
              "niri"
              "umbriel"
            ];
            type = t.enum [
              "button_areas"
              "clickfinger"
            ];
            description = "Use button areas or clickfinger.";
          };
          tap_button_map = mkNullableOption {
            applies = [
              "niri"
              "umbriel"
            ];
            type = t.enum [
              "left_right_middle"
              "left_middle_right"
            ];
            description = "Buttons for one-, two-, and three-finger taps.";
          };
        };
      };
    };

    cursor = mkOption {
      applies = [
        "niri"
        "umbriel"
      ];
      default = { };
      description = "Cursor settings.";
      type = t.submodule {
        options = {
          theme = mkNullableOption {
            applies = [
              "niri"
              "umbriel"
            ];
            type = t.str;
            description = "Xcursor theme; empty uses the environment default.";
          };
          size = mkNullableOption {
            applies = [
              "niri"
              "umbriel"
            ];
            type = t.ints.between 1 512;
            description = "Cursor size in logical pixels.";
          };
          hardware_cursor = mkNullableOption {
            applies = [ "umbriel" ];
            type = t.bool;
            description = "Use a hardware cursor plane when available.";
          };
          hide_when_typing = mkNullableOption {
            applies = [
              "niri"
              "umbriel"
            ];
            type = t.bool;
            description = "Hide after a non-modifier key press.";
          };
          hide_timeout_ms = mkNullableOption {
            applies = [
              "niri"
              "umbriel"
            ];
            type = t.ints.between 0 3600000;
            description = "Hide after inactivity; 0 disables the timeout.";
          };
        };
      };
    };
  };
}
