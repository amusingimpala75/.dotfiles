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
      opacity = 1.0;

      font = {
        family.fixed-pitch = "Maple Mono NF CN";
        family.variable-pitch = "Liberation Serif";
        size = 20;
      };

      emacs = {
        theme-package =
          epkgs:
          epkgs.nord-theme.overrideAttrs (_: {
            patches = [ ./0001-add-lexical-binding-cookie.patch ];
          });
        theme-file-name = "nord-theme";
        theme-name = "nord";
      };
    };

    home.packages = [
      pkgs.maple-mono.NF-CN-unhinted
      pkgs.liberation_ttf
    ];
  };
}
