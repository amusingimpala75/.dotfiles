{
  lib,
  self,
  ...
}:
{
  flake.wrappers = {
    sketchybar =
      {
        pkgs,
        ...
      }:
      {
        imports = [ self.wrapperModules.sketchybar-wrapper ];

        config = {
          type = "lua";
          config = ''
            require('init')
          '';

          luaPackages =
            ps:
            let
              buildFennelPackage = pkgs.buildFennelPackage.override { lua54Packages = ps; };
            in
            [
              (buildFennelPackage {
                name = "sketchybar-config";
                src = lib.sourceFilesBySuffices ./. [ ".fnl" ];
              })
              (pkgs.rift-lua.override { lua55Packages = ps; })
              ps.fennel
            ];

          extraPackages' = [
            pkgs.maple-mono.NF-CN-unhinted
          ];
        };
      };

    sketchybar-wrapper =
      {
        config,
        pkgs,
        wlib,
        ...
      }:
      {
        imports = [ wlib.modules.default ];

        options = {
          type = lib.mkOption {
            default = "bash";
            type = lib.types.enum [
              "lua"
              "bash"
            ];
          };

          config = lib.mkOption {
            default = "";
            type = lib.types.lines;
          };

          luaPackages = lib.mkOption {
            default = ps: [ ];
            type = lib.types.functionTo (lib.types.listOf lib.types.package);
          };

          sbarluaPackage = lib.mkPackageOption pkgs "sbarlua" { };

          luaPackage = lib.mkOption {
            type = lib.types.package;
            default = config.sbarluaPackage.passthru.luaModule;
          };

          extraPackages' = lib.mkOption {
            type = lib.types.listOf lib.types.package;
            default = [ ];
          };
        };

        config = {
          package = pkgs.symlinkJoin {
            name = "sketchybar";
            paths = [ pkgs.sketchybar ] ++ config.extraPackages';
          };

          prefixVar =
            let
              ps = config.luaPackage.pkgs;
              allLuaPackages = (config.luaPackages ps) ++ [ config.sbarluaPackage ];
            in
            lib.mkIf (config.type == "lua") [
              [
                "LUA_PATH"
                ";"
                "${lib.concatMapStringsSep ";" ps.getLuaPath allLuaPackages}"
              ]
              [
                "LUA_CPATH"
                ";"
                "${lib.concatMapStringsSep ";" ps.getLuaCPath allLuaPackages}"
              ]
            ];
          flags."--config" = pkgs.writeTextFile {
            name = "sketchybar-config";
            text = ''
              #!${lib.getExe (if config.type == "lua" then config.luaPackage else pkgs.bash)}
              ${config.config}
            '';
            executable = true;
          };
        };
      };
  };

  flake.modules.homeManager.sketchybar = {
    imports = [ self.wrappers.sketchybar.install ];
    wrappers.sketchybar.enable = true;
  };

  perSystem =
    {
      pkgs,
      ...
    }:
    {
      packages = lib.optionalAttrs pkgs.stdenv.hostPlatform.isDarwin {
        sketchybar = self.wrappers.sketchybar.wrap {
          inherit pkgs;
        };
      };

      wrappers.packages = {
        sketchybar-wrapper = true;
        sketchybar = true;
      };
    };
}
