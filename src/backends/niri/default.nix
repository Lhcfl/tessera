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
    (import ../lib {
      inherit lib pkgs;
      name = "niri";
    })
    mkProvideContextOptions
    mkDestination
    mkIncludes
    percentage
    ;
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
    out.text =
      let
        rmap = lib.flip map;
      in
      kdl.formats.v1 (
        lib.flatten [
          (rmap cfg.general.autostart (n "spawn-sh-at-startup"))
          (lib.mkIf (cfg.environment != { }) (
            n "environment" (lib.mapAttrsToList (name: value: n name value) cfg.environment)
          ))
          (n "input" [
            (raw "// input settings")
            (lib.mkIf cfg.input.follow-mouse (
              n "focus-follows-mouse" {
                max-scroll-amount = percentage cfg.input.follow-mouse-max-scroll;
              }
            ))
          ])
          (n "binds" (import ./keybinds.nix margs))
          (n "layout" [
            (n "preset-column-widths" (map (n "proportion") cfg.layout.preset-column-widths))
          ])
          (rmap niri-cfg.includes (item: n "include" { optional = item.optional; } item.source))
        ]
      );
  };
}
