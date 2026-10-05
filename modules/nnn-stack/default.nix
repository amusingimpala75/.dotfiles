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
                "~/.dotfiles/modules/flake/nnn-stack/config.kdl"
              ];
            }
          ];
          settings = {
            spawn-at-startup = [
              (lib.getExe pkgs.custom-noctalia-shell)
            ];
          };

          meta.platforms = lib.platforms.linux;
        };

      noctalia-shell =
        {
          pkgs,
          wlib,
          ...
        }:
        {
          imports = [ wlib.wrapperModules.noctalia-shell ];

          outOfStoreConfig = "~/.dotfiles/modules/nnn-stack/noctalia";
          package = pkgs.bleeding.noctalia-shell;

          meta.platforms = lib.platforms.linux;
        };
    };
  };
}
