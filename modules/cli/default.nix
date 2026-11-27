{
  inputs,
  ...
}:
{
  flake.modules.homeManager.cli =
    {
      pkgs,
      ...
    }:
    {
      imports = [
        "${inputs.home-manager}/modules/programs/atuin.nix" # for fzf.nix
        "${inputs.home-manager}/modules/programs/direnv.nix"
        "${inputs.home-manager}/modules/programs/eza.nix"
        "${inputs.home-manager}/modules/programs/fzf.nix"
        "${inputs.home-manager}/modules/programs/git.nix" # for direnv.nix
        "${inputs.home-manager}/modules/programs/mcfly.nix" # for fzf.nix
        "${inputs.home-manager}/modules/programs/zoxide.nix"
        "${inputs.home-manager}/modules/services/tldr-update.nix"
      ];

      nixpkgs.overlays = [ inputs.bible.overlays.default ];

      programs = {
        eza = {
          enable = true;
          icons = "auto";
        };
        fzf.enable = true;
        zoxide.enable = true;
      };

      home = {
        packages = with pkgs; [
          bible.asv
          chafa
          custom-bat
          custom-bottom
          doxx
          fd
          file
          htmlq
          jq
          killall
          ncdu
          ripgrep
          sd
          tlrc
          (if pkgs.stdenv.hostPlatform.isDarwin then darwin.trash else trashy)
          tree
          up
        ];

        shellAliases = {
          tree = "eza -T";
        };
      };

      services.tldr-update = {
        enable = true;
        package = pkgs.tlrc;
      };
    };

  flake-file.inputs.bible = {
    url = "github:amusingimpala75/bible.sh";
    inputs.nixpkgs.follows = "nixpkgs";
  };
}
