{
  lib,
  self,
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

      noctalia = {
        imports = [ self.wrapperModules.noctalia-wrapper ];
      };

      # [TODO] remove once nix-community/nix-wrapper-modules#598 is completed
      noctalia-wrapper =
        {
          config,
          pkgs,
          wlib,
          ...
        }:
        {
          imports = [ wlib.modules.default ];

          options.settings = lib.mkOption {
            type = wlib.types.structuredValueWith {
              nullable = false;
              typeName = "TOML";
            };
            default = { };
          };

          config = {
            package = pkgs.noctalia;
            env.NOCTALIA_CONFIG_HOME = placeholder config.outputName;
            constructFiles.generatedConfig = {
              content = builtins.readFile (
                (pkgs.formats.toml { }).generate config.constructFiles.generatedConfig.relPath config.settings
              );
              output = config.outputName;
              relPath = "noctalia/settings.toml";
            };

            meta.platforms = lib.platforms.linux;
          };
        };
    };
  };
}
