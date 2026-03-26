{
  inputs,
  lib,
  self,
  ...
}:
let
  common = pkgs: {
    nix = {
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
      {
        imports = [
          (common pkgs)
          self.modules.darwin.store-garbage-collect
        ];
        nix.channel.enable = false;
      };
    homeManager.nix =
      { pkgs, ... }:
      {
        imports = [
          (common pkgs)
          self.modules.homeManager.store-garbage-collect
        ];
      };
    nixos.nix =
      { pkgs, ... }:
      {
        imports = [
          (common pkgs)
          self.modules.nixos.store-garbage-collect
        ];
        nix.channel.enable = false;
      };
  };
}
