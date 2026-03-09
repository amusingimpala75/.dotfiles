{
  inputs,
  lib,
  ...
}:
let
  common = pkgs: {
    # nixpkgs.overlays = [ inputs.determinate-nix-cli.overlays.default ];
    nix = {
      gc = {
        automatic = true;
        options = "--delete-older-than 30d";
      };
      nixPath = lib.mapAttrsToList (n: _: "${n}=flake:${n}") inputs;
      package = inputs.determinate-nix-cli.packages.${pkgs.stdenv.hostPlatform.system}.nix-cli;
      registry = lib.mapAttrs (_: flake: { inherit flake; }) inputs;
      settings = {
        eval-cores = 0;
        experimental-features = [
          "flakes"
          "nix-command"
          "pipe-operators"
        ];
        flake-registry = "";
      };
    };
  };
in
{
  flake.modules = {
    darwin.nix =
      { pkgs, ... }:
      lib.mkMerge [
        (common pkgs)
        {
          nix.gc.interval = {
            Weekday = 7;
            Hour = 3;
            Minute = 15;
          };
        }
      ];
    homeManager.nix =
      { pkgs, ... }:
      lib.mkMerge [
        (common pkgs)
        {
          nix.gc.persistent = true;
          nix.gc.dates = "weekly";
        }
      ];
    nixos.nix =
      { pkgs, ... }:
      lib.mkMerge [
        (common pkgs)
        {
          nix.gc.persistent = true;
          nix.gc.dates = "weekly";
        }
      ];
  };
}
