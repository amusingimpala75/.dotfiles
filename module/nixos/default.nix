{ inputs, ... }:
{
  imports = [
    inputs.nixos-wsl.nixosModules.default
    ./nix
    ./zsh
  ];
}
