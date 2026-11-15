{
  lib,
  ...
}:
{
  flake = {
    modules.nixos.nnn-stack =
      {
        pkgs,
        ...
      }:
      {
        programs.niri = {
          enable = true;
          package = pkgs.custom-niri;
        };

        programs.noctalia = {
          enable = true;
          package = pkgs.custom-noctalia;
        };

        services.displayManager.noctalia-greeter = {
          enable = true;
          # passwordlessSyncUsers = [ "your-username" ];
          settings = {
            cursor.size = 24;
            keyboard.layout = "us";
          };
          cursorTheme = {
            package = pkgs.bibata-cursors;
            name = "Bibata-Modern-Ice";
          };
        };
      };

    wrappers = {
      niri =
        {
          pkgs,
          wlib,
          ...
        }:
        {
          imports = [ wlib.wrapperModules.niri ];
          extraSettings = [
            {
              include = [
                { optional = true; }
                "~/.dotfiles/modules/nnn-stack/config.kdl"
              ];
            }
          ];
          settings = {
            spawn-at-startup = [
              (lib.getExe pkgs.custom-noctalia)
            ];
          };

          meta.platforms = lib.platforms.linux;
        };

      noctalia =
        {
          config,
          pkgs,
          wlib,
          ...
        }:
        {
          imports = [ wlib.wrapperModules.noctalia ];
          runtimePkgs = with pkgs; [
            evtest
            qrencode
          ];
          # this really should be PR'd
          constructFiles.settings = lib.mkForce {
            content = builtins.toJSON config.settings;
            output = config.configDrvOutput;
            relPath = "noctalia/settings.toml";
            builder = ''
              ${lib.getExe' pkgs.remarshal "json2toml"} "$1" "$2"
            '';
          };
          meta.platforms = lib.platforms.linux;
        };
    };
  };
}
