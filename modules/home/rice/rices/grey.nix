{ config, lib, pkgs, ... }:
{
  options.rices.grey.enable = lib.mkEnableOption "greyscale rice";
  options.rices.grey.forceFg = lib.mkEnableOption "force the fg to be higher contrast";

  config = lib.mkIf config.rices.grey.enable {
    rice = rec {
      theme = let
        scheme = pkgs.my.schemes.base16.grayscale-light;
      in scheme // lib.optionalAttrs config.rices.grey.forceFg (with scheme; {
        base08 = base05;
        base09 = base04;
        base0A = base05;
        base0B = base04;
        base0C = base05;
        base0D = base04;
        base0E = base05;
        base0F = base04;
      });

      opacity = 1.0;

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
    };
    home.packages = [
      pkgs.iosevka-bin
      (pkgs.iosevka-bin.override { variant = "Etoile"; })
    ];

  };
}
