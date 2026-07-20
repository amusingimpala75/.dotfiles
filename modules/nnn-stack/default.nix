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
          package = self.packages.${pkgs.stdenv.hostPlatform.system}.niri;
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
              (lib.getExe self.packages.${pkgs.stdenv.hostPlatform.system}.noctalia-shell)
            ];
          };
        };

      noctalia-shell =
        {
          wlib,
          ...
        }:
        {
          imports = [ wlib.wrapperModules.noctalia-shell ];

          outOfStoreConfig = "~/.dotfiles/modules/nnn-stack/noctalia";
        };
    };
  };

  perSystem =
    {
      pkgs,
      ...
    }:
    {
      wrappers.packages.niri = true;
      wrappers.packages.noctalia-shell = true;

      packages = lib.optionalAttrs pkgs.stdenv.hostPlatform.isLinux {
        niri = self.wrappers.niri.wrap { inherit pkgs; };
        noctalia-shell = self.wrappers.noctalia-shell.wrap { inherit pkgs; };
      };
    };
}
