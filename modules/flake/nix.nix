{
  inputs,
  lib,
  ...
}:
let
  settings = {
    experimental-features = [
      "flakes"
      "nix-command"
      "pipe-operators"
    ];
    flake-registry = "";
  };
  registry = lib.mapAttrs (_: flake: { inherit flake; }) inputs;
  nixPath = lib.mapAttrsToList (n: _: "${n}=flake:${n}") inputs;
in
{
  flake.modules.darwin.nix =
    { pkgs, ... }:
    {
      nix = {
        inherit nixPath registry settings;
        package = pkgs.nixVersions.nix_2_28;
        gc = {
          automatic = true;
          options = "--delete-older-than 30d";
          interval = {
            Weekday = 7;
            Hour = 3;
            Minute = 15;
          };
        };
      };
    };
  flake.modules.homeManager.nix =
    { pkgs, ... }:
    {
      nix = {
        inherit nixPath registry settings;
        package = pkgs.nixVersions.nix_2_28;
        gc = {
          automatic = true;
          options = "--delete-older-than 30d";
          persistent = true;
          dates = "weekly";
        };
      };
    };
  flake.modules.nixos.nix =
    { pkgs, ... }:
    {
      nix = {
        inherit nixPath registry settings;
        package = pkgs.nixVersions.nix_2_28;
        gc = {
          automatic = true;
          options = "--delete-older-than 30d";
          persistent = true;
          dates = "weekly";
        };
      };
    };
}
