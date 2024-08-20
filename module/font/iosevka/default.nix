{
  family.fixed-pitch = "Iosevka";
  family.variable-pitch = "Iosevka Etoile";
  size = 16;
  module = { lib, pkgs, config, ... }:
  {
    home.packages = [
      pkgs.iosevka-bin
      (pkgs.iosevka-bin.override { variant = "Etoile"; })
    ];
  };
}