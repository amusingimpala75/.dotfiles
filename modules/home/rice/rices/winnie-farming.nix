{
  config,
  lib,
  pkgs,
  ...
}:
{
  options.rices.winnie-farming.enable = lib.mkEnableOption "Winnie the Pooh farming rice";

  config = lib.mkIf config.rices.winnie-farming.enable {
    rice = rec {
      opacity = 0.9;

      font = {
        family.fixed-pitch = "Iosevka";
        family.variable-pitch = "Iosevka Etoile";
        size = 16;
      };

      border = {
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
      };
    };
    home.packages = [
      pkgs.iosevka-bin
      (pkgs.iosevka-bin.override { variant = "Etoile"; })
    ];
  };
}
