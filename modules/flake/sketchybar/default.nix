{
  flake.modules.homeManager.sketchybar =
    {
      pkgs,
      ...
    }:
    {
      programs.sketchybar = {
        config = ''
          require('init')
        '';
        configType = "lua";
        enable = true;
        extraLuaPackages =
          let
            bfp = ps: pkgs.buildFennelPackage.override { lua54Packages = ps; };
          in
          ps: with pkgs; [
            (bfp ps {
              name = "fennel-defaults";
              src = runCommand "defaults.fnl" { } ''
                mkdir -p $out
                cp ${config.rice.fennel-defaults} $out/defaults.fnl
              '';
            })
            (bfp ps {
              name = "sketchybar-config";
              src = lib.sourceFilesBySuffices ./. [ ".fnl" ];
            })
            (rift-lua.override { lua55Packages = ps; })
            ps.fennel
          ];
        service.enable = true;
      };

      programs.wallust.settings = {
        templates.fennel = {
          template = ./wallust/fennel.wallust;
          target = "~/.config/sketchybar/colors.fnl";
        };
        hooks.sketchybar = ''
          killall sketchybar
        '';
      };
    };
}
