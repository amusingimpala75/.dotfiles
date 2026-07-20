{
  self,
  ...
}:
{
  flake.wrappers = {
    delta = {
      imports = [ self.wrapperModules.delta-wrapper ];
      settings = {
        syntax-theme = "ansi";
      };
    };

    delta-wrapper =
      {
        config,
        lib,
        pkgs,
        wlib,
        ...
      }:
      {
        imports = [ wlib.modules.default ];

        options = {
          settings = lib.mkOption {
            type = lib.types.attrs;
            default = { };
          };
        };

        config = {
          package = pkgs.delta;
          flags."--config" = pkgs.writeText "delta-config" (
            lib.generators.toGitINI {
              delta = config.settings;
            }
          );
        };
      };
  };

  perSystem.wrappers.packages.delta-wrapper = true;
}
