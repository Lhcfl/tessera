{ lib, ... }:
let
  types = (import ../lib/types.nix { inherit lib; });

  # Action names are umbriel's `umbriel msg` actions, in object-verb form:
  # `window.focus(left)` is written `window-focus = "left"`. Actions that
  # umbriel splits into several commands (`window-focus-left`, …) take the
  # direction/step as their payload instead.
  actions =
    (lib.mapAttrs (
      _:
      attrs@{ type, ... }:
      lib.mkOption (
        attrs
        // {
          type = (lib.types.either type (lib.types.functionTo type)) // {
            description = "the literal or a function that returns the literal, ${type.description}";
          };
        }
      )
    ))
      {
        # Apps
        spawn = {
          type = lib.types.str;
          description = ''
            spawn command.
          '';
        };

        # Focus
        window-focus = {
          type = types.direction;
          description = ''
            focus the window in the given direction
          '';
        };
        column-focus-tab = {
          type = types.step;
          description = ''
            Focus the previous or next tab in the focused tab group
          '';
        };
        workspace-focus = {
          type = types.step;
          description = ''
            Switch to the previous or next workspace on this output
          '';
        };

        # Move & size
        window-move = {
          type = types.direction;
          description = ''
            move the focused window in the given direction
          '';
        };
        window-move-to-workspace = {
          type = types.workspace-id;
          description = ''
            move window to workspace by id
          '';
        };
        workspace-move = {
          type = types.direction;
          description = ''
            move workspace by direction
          '';
        };
        window-cycle-primary-extent = {
          type = types.unit;
          description = ''
            resize the window
          '';
        };

        # Windows
        window-close = {
          type = types.unit;
          description = ''
            close the focused window
          '';
        };
        window-toggle-floating = {
          type = types.unit;
          description = ''
            toggle floating
          '';
        };
        window-toggle-maximize = {
          type = types.unit;
          description = ''
            maximize the window
          '';
        };
        window-toggle-fullscreen = {
          type = types.unit;
          description = ''
            fullscreen the window
          '';
        };
        window-toggle-pinned = {
          type = types.unit;
          description = ''
            Pin the focused window above other windows
          '';
        };
        column-toggle-tabbed = {
          type = types.unit;
          description = ''
            Tab the rows around the focused window, or stack its tabs
          '';
        };

        # Scratchpad
        window-toggle-scratchpad = {
          type = types.unit;
          description = ''
            Move the focused window to or from a scratchpad
          '';
        };
        scratchpad-toggle = {
          type = types.unit;
          description = ''
            Show or hide the selected scratchpad windows
          '';
        };

        # Workspaces
        workspace-switch = {
          type = types.workspace-id;
          description = ''
            focus workspace by id
          '';
        };

        # System
        cheatsheet-toggle = {
          type = types.unit;
          description = ''
            show help of commands
          '';
        };
        session-quit = {
          type = types.unit;
          description = ''
            quit shell
          '';
        };

        # tessera extension: not an umbriel action, rendered by each backend.
        screenshot = {
          type = types.unit;
          description = ''
            take a screenshot
          '';
        };
      };
in
{
  options.tessera.settings.keybinding = lib.mkOption {
    default = { };
    description = "binds <key> to actions";

    type = lib.types.attrsWith {
      placeholder = "key";

      elemType = lib.types.submodule {
        options = {
          actions = lib.mkOption {
            type = lib.types.attrTag actions;
            description = ''
              The action binds to <key>. You can only select one action.
            '';
          };

          allow-when-locked = lib.mkEnableOption "when locked";

          title = lib.mkOption {
            default = null;
            type = lib.types.nullOr lib.types.str;
            description = "help menu title";
          };
        };
      };
    };
  };
}
