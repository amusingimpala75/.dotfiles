{ inputs, lib, pkgs, ... }:
{
  config.nix = {
    settings = {
      experimental-features = [ "nix-command" "flakes" ];
      flake-registry = "";
    };
    package = pkgs.nixVersions.nix_2_26;
    registry = lib.mapAttrs (_: flake: { inherit flake; }) inputs;
    nixPath = lib.mapAttrsToList(n: _: "${n}=flake:${n}") inputs;
    # channel.enable = false; # Do I want to disable channels?
  };
}
