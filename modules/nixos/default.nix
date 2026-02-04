{ inputs, self, ... }:
{
  imports = with self.modules.nixos; with self.modules.generic; [
    nixpkgs
    nix

    inputs.nixos-wsl.nixosModules.default
    ./pgit
    ./zsh
  ];
}
