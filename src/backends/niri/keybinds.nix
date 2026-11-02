{
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
  inherit (niri) n;

  inherit
    (import ../../lib {
      inherit lib pkgs;
      name = "niri";
    })
    match
    applyProvides
    ;

  # Umbriel-style wheel names are the shared notation; niri spells them
  # WheelScroll*.
  fixNiriKey =
    lib.replaceStrings
      [ "WheelUp" "WheelDown" "WheelLeft" "WheelRight" ]
      [ "WheelScrollUp" "WheelScrollDown" "WheelScrollLeft" "WheelScrollRight" ];

in
lib.flip lib.mapAttrsToList cfg.keybinds (
  key: value:
  let
    inherit (value) title allow-when-locked actions;

    params = lib.foldl (acc: x: acc // x) { } [
      (lib.optionalAttrs (allow-when-locked != false) { inherit allow-when-locked; })
      (lib.optionalAttrs (title != null) { hotkey-overlay-title = title; })
    ];

    body = lib.flip lib.mapAttrsToList actions (
      name: praw:
      let
        param = applyProvides praw niri-cfg.provide;
      in
      match name {
        spawn = n "spawn-sh" param;

        workspace-switch = n "focus-workspace" param;

        window-focus = match param {
          Left = n "focus-column-left";
          Right = n "focus-column-right";
          Up = n "focus-window-up";
          Down = n "focus-window-down";
        };

        window-move = match param {
          Left = n "move-column-left";
          Right = n "move-column-right";
          Up = n "move-window-up";
          Down = n "move-window-down";
        };

        window-move-to-workspace = n "move-column-to-workspace" param;

        workspace-move = match param {
          Left = n "spawn" "notify-send" "Cannot Move Workspace Left!";
          Right = n "spawn" "notify-send" "Cannot Move Workspace Right!";
          Up = n "move-workspace-up";
          Down = n "move-workspace-down";
        };

        column-focus-tab = match param {
          Previous = n "focus-window-up";
          Next = n "focus-window-down";
        };

        workspace-focus = match param {
          Previous = n "focus-workspace-up";
          Next = n "focus-workspace-down";
        };

        window-close = n "close-window";

        session-quit = n "quit";

        window-toggle-maximize = n "maximize-column";

        window-toggle-fullscreen = n "fullscreen-window";

        window-cycle-primary-extent = n "switch-preset-column-width";

        cheatsheet-toggle = n "show-hotkey-overlay";

        window-toggle-floating = n "toggle-window-floating";

        window-toggle-pinned = n "spawn" "notify-send" "niri does not support pinning windows";

        column-toggle-tabbed = n "toggle-column-tabbed-display";

        window-toggle-scratchpad = n "spawn" "notify-send" "niri does not support scratchpads";

        scratchpad-toggle = n "spawn" "notify-send" "niri does not support scratchpads";

        screenshot = n "screenshot";

        # fallback
        "default" = throw (builtins.trace param "${name} not implemented");
      }
    );
  in
  n (fixNiriKey key) params body
)
