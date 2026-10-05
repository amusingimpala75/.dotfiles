{
  self,
  ...
}:
{
  flake.wrappers = {
    bat =
      {
        pkgs,
        ...
      }:
      {
        imports = [ self.wrapperModules.bat-wrapper ];
        flags = {
          "--theme" = "base16";
          "--wrap" = "never";
        };
        extraPackages = with pkgs.bat-extras; [
          batman
          batdiff
          batpipe
          batgrep
          prettybat
        ];
      };

    bat-wrapper =
      {
        config,
        lib,
        pkgs,
        wlib,
        ...
      }:
      {
        imports = [ wlib.modules.default ];
        options.extraPackages = lib.mkOption {
          type = lib.types.listOf lib.types.package;
          default = [ ];
        };

        config.package = pkgs.symlinkJoin {
          name = "bat";
          paths = [ pkgs.bat ] ++ config.extraPackages;
          meta.mainProgram = "bat";
        };
      };
  };
}
