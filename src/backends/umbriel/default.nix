{
  config,
  lib,
  pkgs,
  options,
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

  nonNull = lib.filterAttrs (_: value: value != null);
in
{
  imports = [
    ./window-rule.nix
    ./layer-rule.nix
    ./keybinds.nix
  ];

  options.tessera.umbriel = {
    enable = lib.mkEnableOption "unified compositor settings for Umbriel";
    provide = mkProvideContextOptions;
    out = mkDestination;
    includes = mkIncludes;

    keybinds = lib.mkOption {
      type = options.tessera.settings.keybinds.type;
      default = { };
      description = "Umbriel-only keybinds, merged over tessera.settings.keybinds.";
    };

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

      input = {
        focus = {
          follows_mouse = cfg.input.follow-mouse;
          follows_mouse_max_scroll = cfg.input.follow-mouse-max-scroll;
        };

        cursor = nonNull (
          cfg.input.cursor
          // {
            follows_focus = cfg.input.mouse-follows-focus;
          }
        );

        touchpad = nonNull cfg.input.touchpad;
      };

      appearance = nonNull (
        cfg.appearance
        // {
          blur = removeAttrs (nonNull cfg.appearance.blur) [ "offset" ];
        }
      );

      colors.border = nonNull cfg.colors.border;

      layout = {
        extent_presets = cfg.layout.preset-column-widths;
      }
      // nonNull {
        gap = cfg.layout.gap;
        struts = nonNull cfg.layout.struts;
        scrolling = nonNull cfg.layout.scrolling;
      };

      output = lib.mapAttrs (
        _: output:
        nonNull (
          output
          // {
            position =
              if output.position == null then
                null
              else
                [
                  output.position.x
                  output.position.y
                ];
          }
        )
      ) cfg.outputs;
    };
  };
}
