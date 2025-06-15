{ config, lib, pkgs, ... }:
{
  options.my.games = {
    brogue = {
      enable = lib.mkEnableOption "use brogue";
      package = lib.mkOption {
        type = lib.types.package;
        default = if pkgs.stdenv.isDarwin then pkgs.brogue-ce-darwin else pkgs.brogue-ce;
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
    home.packages = (lib.optionals config.my.games.brogue.enable [
      config.my.games.brogue.package
    ]) ++ (lib.optionals config.my.games.dwarf-fortress.enable [
      (pkgs.dwarf-fortress-full.override {
        theme = config.my.games.dwarf-fortress.theme;
      })
    ]) ++ (lib.optionals config.my.games.modrinth.enable [
      pkgs.stable.modrinth-app
    ]);
  };
}
