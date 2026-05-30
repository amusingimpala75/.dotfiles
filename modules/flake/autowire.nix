{
  ...
}:
rec {
  # Reusable autowiring flake
  flake.flakeModules.autowire =
    {
      config,
      lib,
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
          templates = lib.mkIf config.autowire.templates.enable (
            builtins.mapAttrs (name: _: {
              path = config.autowire.templates.path + "/${name}";
              inherit (import (config.autowire.templates.path + "/${name}/flake.nix")) description;
            }) (builtins.readDir config.autowire.templates.path)
          );
        };

        perSystem =
          {
            self',
            ...
          }:
          {
            apps =
              self'.packages
              |> lib.filterAttrs (_: v: v.meta ? mainProgram)
              |> builtins.mapAttrs (
                _: pkg: {
                  type = "app";
                  program = lib.getExe pkg;
                  meta.description = pkg.meta.description or "";
                }
              );
          };
      };
    };

  # Autowire this flake
  imports = [ flake.flakeModules.autowire ];
  autowire = {
    apps.enable = true;
    templates.enable = true;
  };
}
