{ lib, config, ... }: {
  imports = [ ../src ];

  config.files = lib.mapAttrs (_: value: value.out // { enable = value.enable; }) (
    removeAttrs config.tessera [ "settings" ]
  );
}
