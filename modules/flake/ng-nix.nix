{
  inputs,
  self,
  ...
}:
{
  flake.modules.homeManager.ng-nix =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    {
      imports = [
        inputs.nix-index-database.homeModules.nix-index
        self.modules.homeManager.nix-init
      ];

      options.ng-nix = {
        dotfilesDir = lib.mkOption {
          type = lib.types.str;
          default = "~/.dotfiles";
          example = "~/git/dotfiles";
          description = "path to dotfiles";
        };
      };

      config = {
        programs = {
          nh = {
            enable = true;
            flake =
              if lib.strings.hasPrefix "~" config.ng-nix.dotfilesDir then
                (lib.concatStrings [
                  config.home.homeDirectory
                  (builtins.substring 1 (-1) config.ng-nix.dotfilesDir)
                ])
              else
                config.ng-nix.dotfilesDir;
          };

          nix-index.enable = false;
          nix-index-database.comma.enable = true;
        };

        home = {
          shellAliases = {
            nds = "nix develop -c $SHELL";
          };
          packages = with pkgs; [
            nix-tree
            (writeShellApplication {
              name = "ns";
              runtimeInputs = [
                fzf
                nix-search-tv
              ];
              text = builtins.readFile "${nix-search-tv.src}/nixpkgs.sh";
            })
          ];
        };
      };
    };

  flake-file.inputs.nix-index-database = {
    url = "github:nix-community/nix-index-database";
    inputs.nixpkgs.follows = "nixpkgs";
  };
}
