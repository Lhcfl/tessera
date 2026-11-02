{
  description = "Unified compositor settings for tiling Wayland compositors";

  inputs = {
    nix-kdl.url = "github:Lhcfl/nix-kdl";
  };

  outputs =
    { ... }:
    {
      homeModules.default = ./modules/home-manager.nix;
      hjemModules = ./modules/home-manager.nix;
    };
}
