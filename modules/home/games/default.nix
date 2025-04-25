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
  };

  config = {
    home.packages = (lib.optionals config.my.games.brogue.enable [
      config.my.games.brogue.package
    ]);
  };
}
