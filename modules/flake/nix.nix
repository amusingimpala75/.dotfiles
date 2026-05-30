{
  inputs,
  lib,
  self,
  ...
}:
let
  common = pkgs: {
    nix = {
      nixPath = [ ];
      registry = lib.mapAttrs (_: flake: { inherit flake; }) inputs;
      package = pkgs.nix;
      settings = {
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
      { config, pkgs, ... }:
      {
        imports = [
          (common pkgs)
          self.modules.homeManager.store-garbage-collect
        ];
        sops.secrets."gh_ro_public_api_key" = { };
        sops.templates."nix-gh-ro-access.conf" = {
          content = ''
            access-tokens = github.com=${config.sops.placeholder.gh_ro_public_api_key}
          '';
        };
        nix.extraOptions = ''
          !include ${config.sops.templates."nix-gh-ro-access.conf".path}
        '';
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
