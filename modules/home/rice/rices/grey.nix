{
  config,
  lib,
  pkgs,
  ...
}:
{
  options.rices.grey.enable = lib.mkEnableOption "greyscale rice";
  options.rices.grey.forceFg = lib.mkEnableOption "force the fg to be higher contrast";

  config = lib.mkIf config.rices.grey.enable {
    rice = rec {
      opacity = 1.0;

      font = {
        family.fixed-pitch = "Iosevka";
        family.variable-pitch = "Iosevka Etoile";
        size = 16;
      };

      border = {
        width = 4; # pixels
      };

      gaps = rec {
        inner = border.width / 2;
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
