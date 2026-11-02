{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.tessera.settings;
  umbriel-cfg = config.tessera.umbriel;
  toml = pkgs.formats.toml { };

  inherit
    (import ../../lib {
      inherit lib pkgs;
      name = "umbriel";
    })
    mkProvideContextOptions
    mkDestination
    mkIncludes
    ;

  filterIncludes =
    optional:
    lib.pipe umbriel-cfg.includes [
      (builtins.filter (item: item.optional == optional))
      (map (x: x.source))
    ];
in
{
  imports = [
    ./window-rule.nix
    ./layer-rule.nix
  ];

  options.tessera.umbriel = {
    enable = lib.mkEnableOption "unified compositor settings for Umbriel";
    provide = mkProvideContextOptions;
    out = mkDestination;
    includes = mkIncludes;

    settings = lib.mkOption {
      description = "actual umbriel settings.";
      type = toml.type;
    };
  };

  config.tessera.umbriel = {
    provide = {
      # umbriel has at most 64 workspaces
      workspace.empty.id = 64;
    };

    out.target = ".config/umbriel/config.toml";
    out.source = toml.generate "tessera-umbriel-config" umbriel-cfg.settings;

    settings = {
      inherit (cfg) environment;

      general.autostart = cfg.general.autostart;

      include.files = filterIncludes false;
      include.optional.files = filterIncludes true;

      input.focus = {
        follows_mouse = cfg.input.follow-mouse;
        follows_mouse_max_scroll = cfg.input.follow-mouse-max-scroll;
      };

      input.cursor = {
        follows_focus = cfg.input.mouse-follows-focus;
      };

      layout = {
        extent_presets = cfg.layout.preset-column-widths;
      };
    };
  };
}
