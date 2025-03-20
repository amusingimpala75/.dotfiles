{ config, lib, pkgs, userSettings, ... }: let
  cfg = config.my.sketchybar;
  stdenv = pkgs.stdenv;

  lua = pkgs.lua54Packages.lua.withPackages (ps: [
    ps.lua
    pkgs.sbarlua
    (pkgs.callPackage ./config.nix {
      bar-height = userSettings.bar.height;
      bar-isTop = userSettings.bar.isTop;
      border-active = userSettings.border.active;
      border-width = userSettings.border.width;
      inherit (userSettings) theme;
      font-family-fixed = userSettings.font.family.fixed-pitch;
      font-family-variable = userSettings.font.family.variable-pitch;
      font-size = userSettings.font.size;
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
