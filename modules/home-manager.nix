{ lib, config, ... }: {
  imports = [ ../src ];

  config.home.file = lib.mapAttrs (_: value: value.out // { enable = value.enable; }) (
    removeAttrs config.tessera [ "settings" ]
  );
}
