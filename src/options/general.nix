{ lib, ... }:
let
  inherit
    (import ../lib {
      inherit lib;
      pkgs = null;
      name = "options";
    })
    mkOption
    ;
  t = lib.types;
in
{
  options.tessera.settings = {
    general.autostart = mkOption {
      applies = [
        "niri"
        "umbriel"
      ];
      type = t.listOf t.str;
      default = [ ];
      example = [ "fcitx5" ];
      description = "Shell commands to run when the WM session starts.";
    };

    environment = mkOption {
      applies = [
        "niri"
        "umbriel"
      ];
      type = t.attrsOf t.str;
      default = { };
      description = "Environment variables to set for the WM session.";
    };
  };
}
