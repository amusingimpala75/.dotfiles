{ config, lib, pkgs, ... }:
{
  options.my.games = {
    brogue = {
      enable = lib.mkEnableOption "use brogue";
      package = lib.mkOption {
        type = lib.types.package;
        default = pkgs.brogue-ce;
      };
    };
    dwarf-fortress = {
      enable = lib.mkEnableOption "use dwarf fortress";
      theme = lib.mkOption {
        type = lib.types.package;
        default = pkgs.dwarf-fortress-packages.themes.spacefox;
      };
    };
  };

  config = {
    home.packages = (lib.optionals config.my.games.brogue.enable [
      config.my.games.brogue.package
    ]) ++ (lib.optionals config.my.games.dwarf-fortress.enable [
      (pkgs.dwarf-fortress-full.override {
        theme = config.my.games.dwarf-fortress.theme;
      })
    ]);
  };
}
