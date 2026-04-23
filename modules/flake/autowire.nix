{
  ...
}:
rec {
  # Reusable autowiring flake
  flake.flakeModules.autowire =
    {
      config,
      inputs,
      lib,
      self,
      ...
    }:
    {
      options.autowire = {
        # I wish we didn't have to do this,
        # but if we use the self parameter,
        # it instead becomes a string and
        # we become unable to pass some of
        # the checks (because a path isn't
        # recognized as a string for the
        # template check
        root = lib.mkOption {
          default = ../../.;
          description = "root of the flake";
        };
        apps = {
          enable = lib.mkEnableOption "applications for all packages";
        };
        configurations = {
          path = lib.mkOption {
            description = "path at root of configurations";
            default = config.autowire.root + "/configurations";
            type = lib.types.path;
          };
          home = {
            enable = lib.mkEnableOption "autowire home configurations";
            path = lib.mkOption {
              description = "path from which to autowire home configurations";
              default = config.autowire.configurations.path + "/home";
              type = lib.types.path;
            };
          };
        };
        overlays = {
          enable = lib.mkEnableOption "autowire overlays";
          path = lib.mkOption {
            description = "path from which to autowire overlays";
            default = config.autowire.root + "/overlays";
            type = lib.types.path;
          };
        };
        templates = {
          enable = lib.mkEnableOption "autowire templates";
          path = lib.mkOption {
            description = "path from which to autowire templates";
            default = config.autowire.root + "/templates";
            type = lib.types.path;
          };
        };
      };

      config = {
        flake = {
          overlays = lib.mkIf config.autowire.overlays.enable (
            lib.mapAttrs' (name: _: {
              name = lib.removeSuffix ".nix" name;
              value = import (config.autowire.overlays.path + "/${name}");
            }) (builtins.readDir config.autowire.overlays.path)
          );

          templates = lib.mkIf config.autowire.templates.enable (
            builtins.mapAttrs (name: _: {
              path = config.autowire.templates.path + "/${name}";
              inherit (import (config.autowire.templates.path + "/${name}/flake.nix")) description;
            }) (builtins.readDir config.autowire.templates.path)
          );
        };

        perSystem =
          { pkgs, self', ... }:
          {
            apps =
              self'.packages
              |> lib.filterAttrs (_: v: v.meta ? mainProgram)
              |> builtins.mapAttrs (
                _: pkg: {
                  type = "app";
                  program = lib.getExe pkg;
                  meta.description = pkg.meta.description;
                }
              );

            legacyPackages.homeConfigurations = lib.mkIf config.autowire.configurations.home.enable (
              builtins.mapAttrs (
                name: _:
                inputs.home-manager.lib.homeManagerConfiguration {
                  inherit pkgs;
                  modules = [
                    (config.autowire.configurations.home.path + "/${name}")
                    (config.autowire.root + "/modules/home")
                  ];
                  extraSpecialArgs = { inherit inputs self; };
                }
              ) (builtins.readDir config.autowire.configurations.home.path)
            );
          };
      };
    };

  # Autowire this flake
  imports = [ flake.flakeModules.autowire ];
  autowire = {
    apps.enable = true;
    configurations.home.enable = true;
    overlays.enable = true;
    templates.enable = true;
  };
}
