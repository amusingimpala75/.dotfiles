{ inputs, ... }:
{
  imports = [
    inputs.nixos-wsl.nixosModules.default
    ../shared
    ./zsh
  ];
}
