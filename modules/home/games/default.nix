{
  config,
  lib,
  pkgs,
  ...
}:
{
  options.my.games = {
    brogue = {
      enable = lib.mkEnableOption "use brogue";
      terminal = lib.mkEnableOption "terminal support for Brogue";
      graphics = lib.mkOption {
        type = lib.types.bool;
        default = true;
        example = false;
        description = "graphics support for Brogue";
      };
      package = lib.mkOption {
        type = lib.types.package;
        default = pkgs.brogue-ce.override {
          terminal = config.my.games.brogue.terminal;
          graphics = config.my.games.brogue.graphics;
        };
        description = "package to use for brogue";
      };
    };
    dwarf-fortress = {
      enable = lib.mkEnableOption "use dwarf fortress";
      theme = lib.mkOption {
        type = lib.types.package;
        default = pkgs.dwarf-fortress-packages.themes.spacefox;
      };
    };
    modrinth = {
      enable = lib.mkEnableOption "use the Modrinth minecraft launcher";
    };
  };

  config = {
    home.packages =
      (lib.optionals config.my.games.brogue.enable [
        config.my.games.brogue.package
      ])
      ++ (lib.optionals config.my.games.dwarf-fortress.enable [
        (pkgs.dwarf-fortress-full.override {
          theme = config.my.games.dwarf-fortress.theme;
        })
      ])
      ++ (lib.optionals config.my.games.modrinth.enable [
        pkgs.stable.modrinth-app
      ]);
  };
}
