{ inputs, lib, pkgs, ... }:
{
  config.nix = {
    settings.experimental-features = [ "nix-command" "flakes" ];
    package = pkgs.nix;
  };
}
