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
  options.tessera.settings.hotkey_overlay = mkOption {
    applies = [ "niri" ];
    default = { };
    description = "Niri hotkey overlay settings.";
    type = t.submodule {
      options = {
        hide_not_bound = mkNullableOption {
          applies = [ "niri" ];
          type = t.bool;
          description = "Hide actions that are not bound.";
        };
        skip_at_startup = mkNullableOption {
          applies = [ "niri" ];
          type = t.bool;
          description = "Do not show the overlay at startup.";
        };
      };
    };
  };
}
