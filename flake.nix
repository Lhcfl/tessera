{
  description = "Unified compositor settings for tiling Wayland compositors";

  inputs = {
    nix-kdl.url = "github:Lhcfl/nix-kdl";
  };

  outputs =
    { nix-kdl, ... }:
    let
      specialArgs = { inherit nix-kdl; };
      withSpecialArgs = file: {
        imports = [ file ];
        _module.args = specialArgs;
      };
    in
    {
      homeModules.default = withSpecialArgs ./modules/home-manager.nix;
      hjemModules.default = withSpecialArgs ./modules/hjem.nix;
    };
}
