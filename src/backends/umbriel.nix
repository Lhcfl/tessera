{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.tessera.settings;
  toml = pkgs.formats.toml { };

  inherit
    (import ../lib {
      inherit lib;
      name = "umbriel";
    })
    match
    mkProvideContextOptions
    mkDestination
    ;
in
{
  options.tessera.umbriel = {
    enable = lib.mkEnableOption "unified compositor settings for Umbriel";
    provide = mkProvideContextOptions;
    destination = mkDestination;
  };

  config.tessera.umbriel = {
    provide = {
      # umbriel has at most 64 workspaces
      workspace.empty.id = 64;
    };

    out.target = ".config/umbriel/config.toml";
    out.source = toml.generate "tessera-umbriel-config" {

      general.autostart = cfg.spawn-at-startup;
      inherit (cfg) environment;

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

      keybinds = lib.flip lib.mapAttrs cfg.keybinding (
        _:
        {
          actions,
          allow-when-locked,
          ...
        }:
        let
          action = builtins.head (builtins.attrNames actions);
          praw = actions.${action};
          params = if lib.isFunction praw then praw { new-workspace-id = 64; } else praw;
        in
        {
          action = match action {
            spawn = "spawn:${builtins.concatStringsSep " " params}";

            spawn-sh = "spawn:${params}";

            focus-workspace = "workspace-switch:${toString params}";

            focus-window-relative = "window-focus-" + (lib.strings.toLower params);

            move-window-relative = match params {
              Left = "column-move-left";
              Right = "column-move-right";
              Up = "window-move-or-workspace-up";
              Down = "window-move-or-workspace-down";
            };

            move-workspace-relative = match params {
              Left = "spawn:notify-send \"Cannot Move Workspace Left!\"";
              Right = "spawn:notify-send \"Cannot Move Workspace Right!\"";
              Up = "workspace-move-up";
              Down = "workspace-move-down";
            };

            move-window-to-workspace = "window-move-to-workspace:${toString params}";

            screenshot = lib.mkMerge [
              (lib.mkIf config.funkcia.hm.gui.noctalia.enable "spawn:noctalia msg screenshot-fullscreen")
              (lib.mkIf (!config.funkcia.hm.gui.noctalia.enable) "spawn:notify-send no-screenshot-action")
            ];

            close-window = "window-close";

            quit = "session-quit";

            maximize = "window-toggle-maximize";

            fullscreen = "window-toggle-fullscreen";

            resize-preset = "window-cycle-primary-extent";

            show-help = "cheatsheet-toggle";

            toggle-window-floating = "window-toggle-floating";

            toggle-window-pinned = "window-toggle-pinned";

            toggle-column-tabbed = "column-toggle-tabbed";

            focus-column-tab-relative = match params {
              Previous = "column-focus-tab-previous";
              Next = "column-focus-tab-next";
            };

            focus-workspace-relative = match params {
              Previous = "workspace-previous";
              Next = "workspace-next";
            };

            toggle-window-scratchpad = "window-toggle-scratchpad";

            toggle-scratchpad = "scratchpad-toggle";
          };

          allow_when_locked = allow-when-locked;
        }
      );
    };
  };
}
