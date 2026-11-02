{ lib, ... }:
let
  inherit
    (import ../lib {
      inherit lib;
      pkgs = null;
      name = "options";
    })
    mkNullableOption
    ;
  t = lib.types;
in
{
  options.tessera.settings.screenshot.path = mkNullableOption {
    applies = [ "niri" ];
    type = t.str;
    description = "Path template for niri screenshots.";
  };
}
