{ inputs, ... }:
{
  imports = [
    inputs.nixos-wsl.nixosModules.default
    ./nix
    ../shared
    ./zsh
  ];
}
