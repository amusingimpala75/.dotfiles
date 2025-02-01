{ lib, config, pkgs, userSettings, ... }: let
  lua = pkgs.lua54Packages.lua.withPackages (ps: [
    ps.lua
    pkgs.sbarlua
    (pkgs.callPackage ./config.nix { inherit userSettings; })
  ]);
  sketchybarrc = pkgs.writeScript "sketchybarrc"
  ''
    #!${lua}/bin/lua
    package.cpath = package.cpath .. ";${lua}/lib/?.so"
    defaults = require('defaults')
    require('init')
  '';
in {
  home.packages = lib.mkIf pkgs.stdenv.isDarwin [ pkgs.sketchybar ];

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
}
