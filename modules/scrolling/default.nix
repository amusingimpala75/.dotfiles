let
  darwin-rift =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    {
      launchd.agents.rift = lib.mkIf pkgs.stdenv.isDarwin {
        enable = true;
        config = {
          ProgramArguments = [
            "/usr/bin/env"
            "sh"
            "-c"
            "${lib.getExe pkgs.rift-wm}"
          ];
          RunAtLoad = true;
          KeepAlive = true;
        };
      };

      xdg.configFile."rift/config.toml".source =
        config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.dotfiles/modules/flake/scrolling/rift.toml";

      home.packages = [ pkgs.rift-wm ];
    };
in
{
  flake.modules.homeManager.scrolling = {
    imports = [ darwin-rift ];
  };
}
