{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.tessera.settings;
  umbriel-cfg = config.tessera.umbriel;

  inherit
    (import ../../lib {
      inherit lib pkgs;
      name = "umbriel";
    })
    match
    applyProvides
    ;
in
{
  config.tessera.umbriel.settings.keybinds = lib.flip lib.mapAttrs cfg.keybinds (
    _:
    {
      actions,
      allow-when-locked,
      ...
    }:
    let
      action = builtins.head (builtins.attrNames actions);
      params = applyProvides actions.${action} umbriel-cfg.provide;
    in
    {
      action = match action {
        spawn = "spawn:${params}";

        workspace-switch = "workspace-switch:${toString params}";

        window-focus = "window-focus-" + (lib.strings.toLower params);

        window-move = match params {
          Left = "column-move-left";
          Right = "column-move-right";
          Up = "window-move-or-workspace-up";
          Down = "window-move-or-workspace-down";
        };

        window-move-to-workspace = "window-move-to-workspace:${toString params}";

        workspace-move = match params {
          Left = "spawn:notify-send \"Cannot Move Workspace Left!\"";
          Right = "spawn:notify-send \"Cannot Move Workspace Right!\"";
          Up = "workspace-move-up";
          Down = "workspace-move-down";
        };

        column-focus-tab = match params {
          Previous = "column-focus-tab-previous";
          Next = "column-focus-tab-next";
        };

        workspace-focus = match params {
          Previous = "workspace-previous";
          Next = "workspace-next";
        };

        workspace-focus-history = "workspace-previous";

        window-close = "window-close";

        session-quit = "session-quit";

        window-toggle-maximize = "window-toggle-maximize";

        window-toggle-fullscreen = "window-toggle-fullscreen";

        window-cycle-primary-extent = "window-cycle-primary-extent";

        cheatsheet-toggle = "cheatsheet-toggle";

        window-toggle-floating = "window-toggle-floating";

        window-toggle-pinned = "window-toggle-pinned";

        column-toggle-tabbed = "column-toggle-tabbed";

        window-toggle-scratchpad = "window-toggle-scratchpad";

        scratchpad-toggle = "scratchpad-toggle";

        screenshot = lib.mkDefault "spawn:noctalia msg screenshot-fullscreen";
      };

      allow_when_locked = allow-when-locked;
    }
  );
}
