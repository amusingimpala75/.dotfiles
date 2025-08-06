{
  config,
  lib,
  pkgs,
  ...
}:
{
  options.rices.cross.enable = lib.mkEnableOption "Monochrome cross rice";

  config = lib.mkIf config.rices.cross.enable {
    rice = rec {
      theme = pkgs.my.schemes.base16.default-dark;

      emacs = {
        theme-package = pkgs.emacsPackages.miasma-theme;
        theme-file-name = "miasma-theme";
        theme-name = "miasma";
      };

      opacity = 0.9;

      font = {
        family.fixed-pitch = "Iosevka";
        family.variable-pitch = "Iosevka Etoile";
        size = 16;
      };

      border = {
        active = theme.base0E;
        inactive = theme.base02;
        width = 8;
        radius = 12;
      };

      gaps = rec {
        inner = border.radius;
        outer = inner * 2;
      };

      bar = {
        isTop = true;
        height = -config.rice.gaps.outer;
        color = theme.base01;
      };

      wallpaper = "${pkgs.my.wallpapers.simple-cross}";
    };
    home.packages = [
      pkgs.iosevka-bin
      (pkgs.iosevka-bin.override { variant = "Etoile"; })
    ];
  };
}
