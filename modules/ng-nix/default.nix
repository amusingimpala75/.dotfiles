{
  inputs,
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
        "${inputs.home-manager}/modules/programs/nix-index.nix"
        "${inputs.home-manager}/modules/programs/nix-your-shell.nix"
      ];

      programs = {
        nix-index.enable = false;
        nix-index-database.comma.enable = true;

        nix-your-shell = {
          enable = true;
          nix-output-monitor.enable = true;
        };
      };

      home.packages = with pkgs; [
        custom-nh
        custom-nix-init
        custom-nixpkgs-review
        custom-nurl
        nix-tree
        nix-update
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

  flake-file.inputs.nix-index-database = {
    url = "github:nix-community/nix-index-database";
    inputs.nixpkgs.follows = "nixpkgs";
  };
}
