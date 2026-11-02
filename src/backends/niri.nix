{
  nix-kdl,
  config,
  lib,
  ...
}:
let
  cfg = config.tessera.settings;

  inherit (nix-kdl) kdl;
  inherit (kdl.extras) niri;
  inherit (niri) n raw;

  inherit
    (import ../lib {
      inherit lib;
      name = "niri";
    })
    match
    mkProvideContextOptions
    mkDestination
    percentage
    ;
in
{
  options.tessera.niri = {
    enable = lib.mkEnableOption "unified compositor settings for niri";
    provide = mkProvideContextOptions;
    destination = mkDestination;
  };

  config.tessera.niri = {
    provide = {
      # niri has at most 64 workspaces
      workspace.empty.id = 64;
    };

    out.target = ".config/niri/config.kdl";
    out.text =
      let
        rmap = lib.flip map;

        # Umbriel-style wheel names are the shared notation; niri spells them
        # WheelScroll*.
        fixNiriKey =
          lib.replaceStrings
            [ "WheelUp" "WheelDown" "WheelLeft" "WheelRight" ]
            [ "WheelScrollUp" "WheelScrollDown" "WheelScrollLeft" "WheelScrollRight" ];

        binding = lib.flip lib.mapAttrsToList cfg.keybinding (
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
                param = if lib.isFunction praw then praw { new-workspace-id = 255; } else praw;
              in
              match name {
                spawn = n "spawn-sh" param;
                focus-workspace = n "focus-workspace" param;
                focus-window-relative = match param {
                  Left = n "focus-column-left";
                  Right = n "focus-column-right";
                  Up = n "focus-window-up";
                  Down = n "focus-window-down";
                };
                move-window-relative = match param {
                  Left = n "move-column-left";
                  Right = n "move-column-right";
                  Up = n "move-window-up";
                  Down = n "move-window-down";
                };
                move-workspace-relative = match param {
                  Left = n "spawn" "notify-send" "Cannot Move Workspace Left!";
                  Right = n "spawn" "notify-send" "Cannot Move Workspace Right!";
                  Up = n "move-workspace-up";
                  Down = n "move-workspace-down";
                };
                move-window-to-workspace = n "move-column-to-workspace" param;
                screenshot = n "screenshot";
                close-window = n "close-window";
                quit = n "quit";
                maximize = n "maximize-column";
                fullscreen = n "fullscreen-window";
                resize-preset = n "switch-preset-column-width";
                show-help = n "show-hotkey-overlay";
                toggle-window-floating = n "toggle-window-floating";

                toggle-window-pinned = n "spawn" "notify-send" "niri does not support pinning windows";

                toggle-column-tabbed = n "toggle-column-tabbed-display";

                focus-column-tab-relative = match param {
                  Previous = n "focus-window-up";
                  Next = n "focus-window-down";
                };

                focus-workspace-relative = match param {
                  Previous = n "focus-workspace-up";
                  Next = n "focus-workspace-down";
                };

                toggle-window-scratchpad = n "spawn" "notify-send" "niri does not support scratchpads";

                toggle-scratchpad = n "spawn" "notify-send" "niri does not support scratchpads";

                # fallback
                "default" = throw (builtins.trace param "${name} not implemented");
              }
            );
          in
          n (fixNiriKey key) params body
        );
      in
      kdl.formats.v1 (
        lib.flatten [
          (rmap cfg.spawn-at-startup (n "spawn-sh-at-startup"))
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
          (n "binds" binding)
          (n "layout" [
            (n "preset-column-widths" (map (n "proportion") cfg.layout.preset-column-widths))
          ])
        ]
      );
  };
}
