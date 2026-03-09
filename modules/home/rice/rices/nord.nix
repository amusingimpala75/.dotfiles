{
  config,
  lib,
  pkgs,
  ...
}:
{
  options.rices.nord.enable = lib.mkEnableOption "nord rice";

  config = lib.mkIf config.rices.nord.enable {
    rice = {
      theme = pkgs.base1624schemes.base16.nord;

      opacity = 1.0;

      font = {
        family.fixed-pitch = "Maple Mono NF CN";
        family.variable-pitch = "Liberation Serif";
        size = 20;
      };

      emacs = {
        theme-package = pkgs.emacsPackages.nord-theme.overrideAttrs (_: {
          patches = [ ./0001-add-lexical-binding-cookie.patch ];
        });
        theme-file-name = "nord-theme";
        theme-name = "nord";
      };

      wallpaper = pkgs.wallpapers."nord-buildings";
    };

    home.packages = [
      pkgs.maple-mono.NF-CN-unhinted
      pkgs.liberation_ttf
    ];
  };
}
