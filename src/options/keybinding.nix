{ lib, ... }:
let
  types = (import ../lib/types.nix { inherit lib; });

  actions =
    (lib.mapAttrs (
      _:
      attrs@{ type, ... }:
      lib.mkOption (
        attrs
        // {
          type = (lib.types.either type (lib.types.functionTo type)) // {
            description = "X, or a function that takes the context and returns X, where X = ${type.description}";
          };
        }
      )
    ))
      {
        spawn = {
          description = ''
            spawn command.
          '';
          type = lib.types.str;
        };
        focus-workspace = {
          description = ''
            focus workspace by id
          '';
          type = types.workspace-id;
        };
        focus-window-relative = {
          description = ''
            focus window by direction
          '';
          type = types.direction;
        };
        move-window-relative = {
          description = ''
            move window by direction
          '';
          type = types.direction;
        };
        move-window-to-workspace = {
          description = ''
            move window to workspace by id
          '';
          type = types.workspace-id;
        };
        move-workspace-relative = {
          description = ''
            move workspace by direction
          '';
          type = types.workspace-id;
        };
        screenshot = {
          description = ''
            take a screenshot
          '';
          type = types.unit;
        };
        close-window = {
          description = ''
            close the focused window
          '';
          type = types.unit;
        };
        quit = {
          description = ''
            quit shell
          '';
          type = types.unit;
        };
        maximize = {
          description = ''
            maximize the window
          '';
          type = types.unit;
        };
        fullscreen = {
          description = ''
            fullscreen the window
          '';
          type = types.unit;
        };
        resize-preset = {
          description = ''
            resize the window
          '';
          type = types.unit;
        };
        show-help = {
          description = ''
            show help of commands
          '';
          type = types.unit;
        };
        toggle-window-floating = {
          description = ''
            toggle floating
          '';
          type = types.unit;
        };
        toggle-window-pinned = {
          description = ''
            Pin the focused window above other windows
          '';
          type = types.unit;
        };
        toggle-column-tabbed = {
          description = ''
            Tab the rows around the focused window, or stack its tabs
          '';
          type = types.unit;
        };
        focus-column-tab-relative = {
          description = ''
            Focus the previous or next tab in the focused tab group
          '';
          type = types.step;
        };
        focus-workspace-relative = {
          description = ''
            Switch to the previous or next workspace on this output
          '';
          type = types.step;
        };
        toggle-window-scratchpad = {
          description = ''
            Move the focused window to or from a scratchpad
          '';
          type = types.unit;
        };
        toggle-scratchpad = {
          description = ''
            Show or hide the selected scratchpad windows
          '';
          type = types.unit;
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
