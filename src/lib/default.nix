{ lib, name, ... }:
let
  types = (import ./types.nix { inherit lib; });
in
{
  match = str: defs: defs.${str} or defs.default;

  percentage = x: (toString (x * 100)) + "%";

  mkProvideContextOptions = lib.mkOption {
    description = "Provide context options for ${name}.";
    type = lib.types.submodule (
      { ... }: {
        options = {
          workspace.empty.id = lib.mkOption {
            type = types.workspace-id;
            description = "The workspace ID to use for a new empty workspace.";
          };
        };
      }
    );
  };

  mkDestination = {
    target = lib.mkOption {
      description = "The path of the result config file for ${name}. Path to target file relative to HOME.";
      type = lib.types.str;
    };
    text = lib.mkOption {
      description = "The content of the result config file for ${name}. ";
      type = lib.nullOr lib.types.lines;
    };
    source = lib.mkOption {
      description = "The source of the result config file for ${name}.";
      type = lib.types.str;
    };
  };
}
