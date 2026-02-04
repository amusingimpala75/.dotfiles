{
  config,
  inputs,
  lib,
  root,
  self,
  ...
}:
{
  options.autowire = {
    apps = {
      enable = lib.mkEnableOption "applications for all packages";
    };
    configurations = {
      path = lib.mkOption {
        description = "path at root of configurations";
        default = "${root}/configurations";
        type = lib.types.path;
      };
      darwin = {
        enable = lib.mkEnableOption "autowire darwin configurations";
        path = lib.mkOption {
          description = "path from which to autowire darwin configurations";
          default = "${config.autowire.configurations.path}/darwin";
          type = lib.types.path;
        };
      };
      home = {
        enable = lib.mkEnableOption "autowire home configurations";
        path = lib.mkOption {
          description = "path from which to autowire home configurations";
          default = "${config.autowire.configurations.path}/home";
          type = lib.types.path;
        };
      };
      nixos = {
        enable = lib.mkEnableOption "autowire nixos configurations";
        path = lib.mkOption {
          description = "path from which to autowire nixos configurations";
          default = "${config.autowire.configurations.path}/nixos";
          type = lib.types.path;
        };
      };
      nixvim = {
        enable = lib.mkEnableOption "autowire nixvim configurations";
        path = lib.mkOption {
          description = "path from which to autowire nixvim configurations";
          default = "${config.autowire.configurations.path}/nixvim";
          type = lib.types.path;
        };
      };
    };
    overlays = {
      enable = lib.mkEnableOption "autowire overlays";
      path = lib.mkOption {
        description = "path from which to autowire overlays";
        default = "${root}/overlays";
        type = lib.types.path;
      };
    };
    templates = {
      enable = lib.mkEnableOption "autowire templates";
      path = lib.mkOption {
        description = "path from which to autowire templates";
        default = "${root}/templates";
        type = lib.types.path;
      };
    };
  };

  config = {
    flake = {
      darwinConfigurations = lib.mkIf config.autowire.configurations.darwin.enable (
        builtins.mapAttrs (
          name: _:
          inputs.nix-darwin.lib.darwinSystem {
            specialArgs = { inherit inputs root self; };
            modules = [
              "${config.autowire.configurations.darwin.path}/${name}"
              "${root}/modules/darwin"
              config.flake.modules.generic.nixpkgs
            ];
          }
        ) (builtins.readDir "${config.autowire.configurations.darwin.path}")
      );

      nixosConfigurations = lib.mkIf config.autowire.configurations.nixos.enable (
        builtins.mapAttrs (
          name: _:
          inputs.nixpkgs.lib.nixosSystem {
            specialArgs = { inherit inputs root self; };
            modules = [
              "${config.autowire.configurations.nixos.path}/${name}"
              "${root}/modules/nixos"
              config.flake.modules.generic.nixpkgs
            ];
          }
        ) (builtins.readDir "${config.autowire.configurations.nixos.path}")
      );

      overlays = lib.mkIf config.autowire.overlays.enable (
        lib.mapAttrs' (name: _: {
          name = lib.removeSuffix ".nix" name;
          value = import "${config.autowire.overlays.path}/${name}";
        }) (builtins.readDir "${config.autowire.overlays.path}")
      );

      templates = lib.mkIf config.autowire.templates.enable (
        builtins.mapAttrs (name: _: {
          path = "${config.autowire.templates.path}/${name}";
          description = (import "${config.autowire.templates.path}/${name}/flake.nix").description;
        }) (builtins.readDir "${config.autowire.templates.path}")
      );
    };

    perSystem =
      { pkgs, self', ... }:
      {
        apps = builtins.mapAttrs (name: pkg: {
          type = "app";
          program = lib.getExe pkg;
          meta.description = pkg.meta.description;
        }) self'.packages;

        legacyPackages.homeConfigurations = lib.mkIf config.autowire.configurations.home.enable (
          builtins.mapAttrs (
            name: _:
            inputs.home-manager.lib.homeManagerConfiguration {
              inherit pkgs;
              modules = [
                "${config.autowire.configurations.home.path}/${name}"
                "${root}/modules/home"
                config.flake.modules.generic.nixpkgs
              ];
              extraSpecialArgs = { inherit inputs root self; };
            }
          ) (builtins.readDir "${config.autowire.configurations.home.path}")
        );

        nixvimConfigurations = lib.mkIf config.autowire.configurations.nixvim.enable (
          builtins.mapAttrs (
            name: _:
            inputs.nixvim.lib.evalNixvim {
              inherit (pkgs.stdenv.hostPlatform) system;
              modules = [ "${config.autowire.configurations.nixvim.path}/${name}" ];
            }
          ) (builtins.readDir "${config.autowire.configurations.nixvim.path}")
        );
      };
  };
}
