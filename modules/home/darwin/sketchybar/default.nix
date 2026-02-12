{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.my.sketchybar;
  stdenv = pkgs.stdenv;

  wrapFile =
    drv: filename:
    pkgs.stdenv.mkDerivation {
      name = drv.name;
      src = drv;
      phases = [ "buildPhase" ];
      buildPhase = ''
        mkdir -p $out
        cp $src $out/${filename}
      '';
    };

  defaults = pkgs.buildFennelPackage {
    name = "fennel-defaults";
    src = wrapFile config.rice.fennel-defaults "defaults.fnl";
  };

  bar-cfg = pkgs.buildFennelPackage {
    name = "sketchybar-config";
    src = lib.sourceFilesBySuffices ./. [ ".fnl" ];
  };

  lua = pkgs.lua54Packages.lua.withPackages (ps: [
    pkgs.sbarlua
    bar-cfg
    defaults
  ]);

  sketchybarrc = pkgs.writeScript "sketchybarrc" ''
    #!${lua}/bin/lua
    defaults = require('defaults')
    require('init')
  '';
in
{
  options.my.sketchybar = {
    enable = lib.mkEnableOption "my sketchybar configuration";
  };

  config = lib.mkIf (cfg.enable && stdenv.isDarwin) {
    home.packages = [ pkgs.sketchybar ];

    launchd.agents."sketchybar" = {
      enable = true;
      config = rec {
        KeepAlive = true;
        Program = "${lib.getExe pkgs.sketchybar}";
        ProgramArguments = [
          Program
          "-c"
          "${sketchybarrc}"
        ];
      };
    };
  };
}
