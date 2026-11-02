{
  lib,
  ...
}:
let
  inherit
    (import ../lib {
      inherit lib;
      pkgs = null;
      name = "layer-rule";
    })
    mkOption
    mkNullableOption
    ;

  layerEnum =
    with lib.types;
    enum [
      "background"
      "bottom"
      "top"
      "overlay"
    ];

  cornerRadius = with lib.types; either number (listOf number);

  backgroundEffect =
    with lib.types;
    submodule {
      options = {
        noise = mkNullableOption {
          applies = [ "niri" ];
          type = float;
          description = "Amount of pixel noise added to the background.";
        };
        saturation = mkNullableOption {
          applies = [ "niri" ];
          type = float;
          description = "Background color saturation, where 1.0 is normal.";
        };
      };
    };

  shadow =
    with lib.types;
    submodule {
      options = {
        on = mkNullableOption {
          applies = [ "niri" ];
          type = bool;
          description = "Force-enable the shadow for this surface.";
        };
        off = mkNullableOption {
          applies = [ "niri" ];
          type = bool;
          description = "Disable the shadow for this surface. `on` takes precedence.";
        };
        softness = mkNullableOption {
          applies = [ "niri" ];
          type = number;
          description = "Shadow softness/size in logical pixels.";
        };
        spread = mkNullableOption {
          applies = [ "niri" ];
          type = number;
          description = "Expand the shadow rectangle in logical pixels; may be negative.";
        };
        offset = mkNullableOption {
          applies = [ "niri" ];
          type = submodule {
            options = {
              x = mkNullableOption {
                applies = [ "niri" ];
                type = number;
                description = "Horizontal offset in logical pixels.";
              };
              y = mkNullableOption {
                applies = [ "niri" ];
                type = number;
                description = "Vertical offset in logical pixels.";
              };
            };
          };
          description = "Shadow offset in logical pixels.";
        };
        draw_behind_window = mkNullableOption {
          applies = [ "niri" ];
          type = bool;
          description = "Draw the shadow behind the surface rather than only around it.";
        };
        color = mkNullableOption {
          applies = [ "niri" ];
          type = str;
          description = "Shadow color.";
        };
        inactive_color = mkNullableOption {
          applies = [ "niri" ];
          type = str;
          description = "Shadow color for inactive surfaces.";
        };
      };
    };

  popups =
    with lib.types;
    submodule {
      options = {
        opacity = mkNullableOption {
          applies = [ "niri" ];
          type = float;
          description = "Popup surface opacity from 0.0 to 1.0.";
        };
        geometry_corner_radius = mkNullableOption {
          applies = [ "niri" ];
          type = cornerRadius;
          description = "Popup corner radius: one value or four CSS-order values.";
        };
        background_effect = mkNullableOption {
          applies = [ "niri" ];
          type = backgroundEffect;
          description = "Background effect for this surface's popups.";
        };
      };
    };

  matchBlock =
    with lib.types;
    submodule {
      options = {
        namespace = mkNullableOption {
          applies = [
            "niri"
            "umbriel"
          ];
          type = str;
          description = "Match the layer surface namespace with a regular expression.";
        };
        layer = mkNullableOption {
          applies = [
            "niri"
            "umbriel"
          ];
          type = layerEnum;
          description = ''Match the layer-shell layer: "background", "bottom", "top", or "overlay".'';
        };
        at_startup = mkNullableOption {
          applies = [
            "niri"
            "umbriel"
          ];
          type = bool;
          description = "Match during or after the first 60 seconds.";
        };
      };
    };

  matchType = lib.types.nullOr (lib.types.either matchBlock (lib.types.listOf matchBlock));
in
{
  options.tessera.settings.layer-rule = mkOption {
    applies = [
      "niri"
      "umbriel"
    ];
    default = { };
    description = ''
      layer rule settings. every rule should have a unique name.

      Layer rules apply settings to matching layer-shell surfaces. Every
      matching rule contributes its values; when two set the same field, the
      later rule wins.
    '';
    type = lib.types.attrsOf (
      lib.types.submodule {
        options = {
          order = mkOption {
            applies = [
              "niri"
              "umbriel"
            ];
            type = lib.types.raw;
            default = x: x;
            description = ''
              One of `lib.mkBefore`, `lib.mkAfter`, or `lib.mkOrder <number>`.
            '';
          };

          match = mkOption {
            applies = [
              "niri"
              "umbriel"
            ];
            default = null;
            description = ''
              match rules. A single block, a list of blocks, or null to match
              every layer surface.

              The list is combined with OR: the rule matches when any block
              matches. Within one block all selectors are combined with AND.
              Selectors are optional; a block with none matches every surface.
              Regular expressions match any part of a value, so use `^` and `$`
              for an exact match.
            '';
            type = matchType;
          };
        }
        // (with lib.types; {
          blur = mkNullableOption {
            applies = [
              "niri"
              "umbriel"
            ];
            type = bool;
            description = "Enable or disable blur for the layer surface.";
          };
          blur_popups = mkNullableOption {
            applies = [
              "niri"
              "umbriel"
            ];
            type = bool;
            description = "Enable or disable blur for descendant XDG popups.";
          };
          blur_ignore_alpha = mkNullableOption {
            applies = [ "umbriel" ];
            type = float;
            description = "Skip blur below an alpha threshold, from 0.0 to 1.0.";
          };
          blur_optimized = mkNullableOption {
            applies = [
              "niri"
              "umbriel"
            ];
            type = bool;
            description = "Use the optimized (xray) blur for this surface.";
          };

          opacity = mkNullableOption {
            applies = [ "niri" ];
            type = float;
            description = "Surface opacity from 0.0 to 1.0.";
          };
          block_capture = mkNullableOption {
            applies = [ "niri" ];
            type = bool;
            description = "Block the surface out from screencasts and screen captures.";
          };
          shadow = mkNullableOption {
            applies = [ "niri" ];
            type = shadow;
            description = "Override shadow options for this layer surface.";
          };
          geometry_corner_radius = mkNullableOption {
            applies = [ "niri" ];
            type = cornerRadius;
            description = "Corner radius for the surface's shadow: one value or four CSS-order values.";
          };
          place_within_backdrop = mkNullableOption {
            applies = [ "niri" ];
            type = bool;
            description = "Place the surface into the overview backdrop.";
          };
          baba_is_float = mkNullableOption {
            applies = [ "niri" ];
            type = bool;
            description = "Make the surface float up and down (niri April Fools' feature).";
          };
          background_effect = mkNullableOption {
            applies = [ "niri" ];
            type = backgroundEffect;
            description = "Background effect options for this surface.";
          };
          popups = mkNullableOption {
            applies = [ "niri" ];
            type = popups;
            description = "Override properties for this surface's popups.";
          };
        });
      }
    );
  };
}
