{ config, lib, pkgs, ... }:
{
  options.rices.winnie-farming.enable = lib.mkEnableOption "Winnie the Pooh farming rice";

  config = lib.mkIf config.rices.winnie-farming.enable {
    rice = rec {
      theme = pkgs.my.schemes.mocha;

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
        radius = 8;
      };

      gaps = rec {
        inner = border.width * 2;
        outer = inner;
      };

      bar = {
        isTop = true;
        height = 32;
        color = theme.base01;
      };

      wallpaper = "${pkgs.my.wallpapers.winnie-the-pooh-farm}";
    };
    home.packages = [
      pkgs.iosevka-bin
      (pkgs.iosevka-bin.override { variant = "Etoile"; })
    ];
  };
}
