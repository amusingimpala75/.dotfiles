{ config, lib, pkgs, ... }: let
  cfg = config.my.sketchybar;
  rice = config.rice;
  stdenv = pkgs.stdenv;

  lua = pkgs.lua54Packages.lua.withPackages (ps: [
    ps.lua
    pkgs.sbarlua
    (pkgs.callPackage ./config.nix {
      bar-height = rice.bar.height;
      bar-isTop = rice.bar.isTop;
      border-active = rice.border.active;
      border-width = rice.border.width;
      font-family-fixed = rice.font.family.fixed-pitch;
      font-family-variable = rice.font.family.variable-pitch;
      font-size = rice.font.size;
      theme = rice.theme;
    })
  ]);
  sketchybarrc = pkgs.writeScript "sketchybarrc"
  ''
    #!${lua}/bin/lua
    package.cpath = package.cpath .. ";${lua}/lib/?.so" -- TODO fix (i.e. remove this)
    defaults = require('defaults')
    require('init')
  '';
in {
  options.my.sketchybar = {
    enable = lib.mkEnableOption "my sketchybar configuration";
  };

  config = lib.mkIf (cfg.enable && stdenv.isDarwin) {
    home.packages = [ pkgs.sketchybar ];

    launchd.agents."sketchybar" = {
      enable = true;
      config = rec {
        KeepAlive = true;
        Program = "${pkgs.sketchybar}/bin/sketchybar";
        ProgramArguments = [
          Program
          "-c"
          "${sketchybarrc}"
        ];
      };
    };
  };
}
