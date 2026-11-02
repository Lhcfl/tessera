{
  lib,
  pkgs,
  name,
  ...
}:
let
  types = (import ./types.nix { inherit lib; });
in
rec {
  match = str: defs: defs.${str} or defs.default;

  percentage = x: (toString (x * 100)) + "%";

  mkOption =
    args@{ applies, description, ... }:
    lib.mkOption (
      removeAttrs args [ "applies" ]
      // {
        description = description + "\n\nApplies to: " + lib.concatStringsSep ", " applies;
      }
    );

  mkNullableOption =
    { type, ... }@args:
    mkOption (
      args
      // {
        type = lib.types.nullOr type;
      }
    );

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

  mkDestination = lib.mkOption {
    type = lib.types.submodule (
      { config, ... }: {
        options = {
          target = lib.mkOption {
            description = "The path of the result config file for ${name}. Path to target file relative to HOME.";
            type = lib.types.str;
          };
          text = lib.mkOption {
            description = "The content of the result config file for ${name}. ";
            type = lib.types.nullOr lib.types.lines;
            default = null;
          };
          source = lib.mkOption {
            description = "The source of the result config file for ${name}.";
            type = lib.types.path;
            default = pkgs.writeText "tessera-${name}-config" config.text;
          };
        };
      }
    );
  };

  mkIncludes = lib.mkOption {
    description = "Include additional config files for ${name}.";
    type = lib.types.listOf (
      lib.types.submodule (
        { ... }: {
          options = {
            optional = lib.mkOption {
              description = "if the included config file can be missing without causing an error.";
              type = lib.types.bool;
              default = false;
            };

            source = lib.mkOption {
              description = "The source of the included config file for ${name}.";
              type = lib.types.str;
            };
          };
        }
      )
    );
  };

  applyProvides = x: params: if lib.isFunction x then x params else x;
}
