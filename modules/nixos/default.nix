{ inputs, ... }:
{
  imports = [
    inputs.nixos-wsl.nixosModules.default
    ./pgit
    ../shared
    ./zsh
  ];
}
