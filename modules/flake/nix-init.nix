{
  inputs,
  self,
  ...
}:
{
  flake = {
    modules.homeManager.nix-init = {
      imports = [ self.wrappers.nix-init.install ];
      wrappers.nix-init.enable = true;
    };

    wrappers = {
      nix-init = {
        imports = [ self.wrapperModules.nix-init-wrapper ];

        settings = {
          inherit (inputs) nixpkgs;
        };
      };

      nix-init-wrapper =
        {
          config,
          lib,
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
            package = pkgs.nix-init;
            flags."--config" = config.constructFiles.generatedConfig.path;
            constructFiles.generatedConfig = {
              content = builtins.toJSON config.settings;
              relPath = "${config.binName}-config.toml";
              builder = ''${lib.getExe' pkgs.remarshal "json2toml"} "$1" "$2"'';
            };
          };
        };
    };
  };

  perSystem.wrappers.packages.nix-init-wrapper = true;
}
