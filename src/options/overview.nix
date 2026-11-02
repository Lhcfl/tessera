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
  options.tessera.settings.overview.workspace_shadow = mkNullableOption {
    applies = [ "niri" ];
    type = t.bool;
    description = "Draw shadows behind workspace previews in the overview.";
  };
}
