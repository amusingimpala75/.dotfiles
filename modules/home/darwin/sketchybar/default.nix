{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.my.sketchybar;
  inherit (pkgs) stdenv;
  bfp = ps: pkgs.buildFennelPackage.override { lua54Packages = ps; };
in
{
  options.my.sketchybar = {
    enable = lib.mkEnableOption "my sketchybar configuration";
  };

  config = lib.mkIf (cfg.enable && stdenv.isDarwin) {
    programs.sketchybar = {
      config = ''
        require('init')
      '';
      configType = "lua";
      enable = true;
      extraLuaPackages = ps: with pkgs; [
        (bfp ps {
          name = "fennel-defaults";
          src = runCommand "defaults.fnl" {} ''
            mkdir -p $out
            cp ${config.rice.fennel-defaults} $out/defaults.fnl
          '';
        })
        (bfp ps {
          name = "sketchybar-config";
          src = lib.sourceFilesBySuffices ./. [ ".fnl" ];
        })
      ];
      service.enable = true;
    };
  };
}
