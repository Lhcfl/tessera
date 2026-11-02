{
  lib,
  ...
}:
{
  options.tessera.settings = {
    general = {
      autostart = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [ ];
        example = [ "fcitx5" ];
        description = "Shell commands to run when the WM session starts.";
      };
    };

    input = {
      follow-mouse = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Focus the window under the mouse pointer.";
      };

      follow-mouse-max-scroll = lib.mkOption {
        type = lib.types.float;
        default = 0.5;
        description = ''
          Refuse focus-follows-mouse when focusing would scroll the view
          farther than this many viewport widths.
        '';
      };

      mouse-follows-focus = lib.mkEnableOption "moves the cursor to a newly focused window after keyboard-driven focus and transfer actions.";
    };

    environment = lib.mkOption {
      type = lib.types.attrsOf lib.types.str;
      default = { };
      description = "Environment variables to set for the WM session.";
    };

    layout = {
      preset-column-widths = lib.mkOption {
        type = lib.types.listOf lib.types.number;
        default = [
          0.333
          0.5
          0.667
        ];
        description = "Fractions used by `resize-preset` actions.";
      };
    };
  };
}
