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
  options.tessera.settings.colors.border = mkOption {
    applies = [
      "niri"
      "umbriel"
    ];
    default = { };
    description = "Border colors.";
    type = t.submodule {
      options = {
        focused = mkNullableOption {
          applies = [
            "niri"
            "umbriel"
          ];
          type = t.str;
          description = "Color of the focused window's inner border.";
        };
        unfocused = mkNullableOption {
          applies = [
            "niri"
            "umbriel"
          ];
          type = t.str;
          description = "Color of other windows' inner border.";
        };
        outer = mkNullableOption {
          applies = [ "umbriel" ];
          type = t.str;
          description = "Color of the optional outer border.";
        };
      };
    };
  };
}
