{
  config,
  lib,
  pkgs,
  ...
}:
{
  options.rices.woodland.enable = lib.mkEnableOption "woodland rice";

  config = lib.mkIf config.rices.woodland.enable {
    rice = rec {
      theme = pkgs.my.schemes.base16.woodland;

      opacity = 0.9;

      font = {
        family.fixed-pitch = "Iosevka";
        family.variable-pitch = "Iosevka Etoile";
        size = 16;
      };

      border = {
        active = theme.base0E;
        inactive = theme.base02;
        width = 4; # pixels
      };

      gaps = rec {
        inner = border.width / 2;
        outer = inner;
      };

      bar = {
        isTop = true;
        height = 32;
        color = theme.base01;
      };

      wallpaper = "${pkgs.my.wallpapers.gruv-bunny}";
    };

    home.packages = [
      pkgs.iosevka-bin
      (pkgs.iosevka-bin.override { variant = "Etoile"; })
    ];
  };
}
