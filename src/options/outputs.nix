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
  options.tessera.settings.outputs = mkOption {
    applies = [
      "niri"
      "umbriel"
    ];
    default = { };
    description = "Per-output settings.";
    type = t.attrsOf (
      t.submodule {
        options = {
          enabled = mkNullableOption {
            applies = [
              "niri"
              "umbriel"
            ];
            type = t.bool;
            description = "Turn the monitor on or off.";
          };
          mode = mkNullableOption {
            applies = [
              "niri"
              "umbriel"
            ];
            type = t.str;
            description = ''Resolution and optional refresh rate, such as "2560x1440@165".'';
          };
          scale = mkNullableOption {
            applies = [
              "niri"
              "umbriel"
            ];
            type = t.float;
            description = "Output scale from 0.25 to 4.0.";
          };
          transform = mkNullableOption {
            applies = [
              "niri"
              "umbriel"
            ];
            type = t.str;
            description = "Rotation or reflection.";
          };
          position = mkNullableOption {
            applies = [
              "niri"
              "umbriel"
            ];
            type = t.submodule {
              options = {
                x = mkNullableOption {
                  applies = [
                    "niri"
                    "umbriel"
                  ];
                  type = t.int;
                  description = "Horizontal position in logical coordinates.";
                };
                y = mkNullableOption {
                  applies = [
                    "niri"
                    "umbriel"
                  ];
                  type = t.int;
                  description = "Vertical position in logical coordinates.";
                };
              };
            };
            description = "Top-left position in logical coordinates.";
          };
          vrr = mkNullableOption {
            applies = [
              "niri"
              "umbriel"
            ];
            type = t.enum [
              "disabled"
              "always"
              "fullscreen"
            ];
            description = "Variable refresh rate policy.";
          };
          hdr = mkNullableOption {
            applies = [ "umbriel" ];
            type = t.enum [
              "off"
              "on"
              "auto"
              "fullscreen"
            ];
            description = "HDR activation policy.";
          };
          tearing = mkNullableOption {
            applies = [ "umbriel" ];
            type = t.bool;
            description = "Allow eligible fullscreen windows to use asynchronous page flips.";
          };
        };
      }
    );
  };
}
