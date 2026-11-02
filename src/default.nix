{ ... }: {
  imports = [
    ./backends/niri
    ./backends/umbriel
    ./options/default.nix
    ./options/keybinds.nix
    ./options/window-rule.nix
  ];
}
