{
  inputs,
  lib,
  ...
}:
let
  shared =
    {
      pkgs,
      ...
    }:
    {

      home-manager = {
        backupCommand = lib.getExe (
          if pkgs.stdenv.hostPlatform.isDarwin then pkgs.darwin.trash else pkgs.trashy
        );
        minimal = true;
        useUserPackages = true;
        verbose = true;
      };
    };

in
{
  imports = [ inputs.home-manager.flakeModules.home-manager ];

  flake.modules = {
    darwin.home-manager = {
      imports = [
        inputs.home-manager.darwinModules.home-manager
        shared
      ];
    };
    nixos.home-manager = {
      imports = [
        inputs.home-manager.nixosModules.home-manager
        shared
      ];
    };
  };

  flake-file.inputs.home-manager = {
    url = "github:nix-community/home-manager";
    inputs.nixpkgs.follows = "nixpkgs";
  };
}
