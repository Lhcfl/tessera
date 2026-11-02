{ ... }: {
  imports = [
    ./backends/niri.nix
    ./backends/umbriel.nix
    ./options/default.nix
    ./options/keybinding.nix
  ];
}
