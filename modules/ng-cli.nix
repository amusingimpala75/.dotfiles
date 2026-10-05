{
  inputs,
  ...
}:
{
  flake.modules.homeManager.ng-cli =
    {
      pkgs,
      ...
    }:
    {
      imports = [
        "${inputs.home-manager}/modules/programs/atuin.nix" # for fzf.nix
        "${inputs.home-manager}/modules/programs/bat.nix"
        "${inputs.home-manager}/modules/programs/bottom.nix"
        "${inputs.home-manager}/modules/programs/direnv.nix"
        "${inputs.home-manager}/modules/programs/eza.nix"
        "${inputs.home-manager}/modules/programs/fd.nix"
        "${inputs.home-manager}/modules/programs/fish.nix" # for fd.nix
        "${inputs.home-manager}/modules/programs/fzf.nix"
        "${inputs.home-manager}/modules/programs/git.nix" # for direnv.nix
        "${inputs.home-manager}/modules/programs/man" # for fish.nix
        "${inputs.home-manager}/modules/programs/mcfly.nix"
        "${inputs.home-manager}/modules/programs/pay-respects.nix"
        "${inputs.home-manager}/modules/programs/ripgrep.nix"
        "${inputs.home-manager}/modules/programs/zoxide.nix"
        "${inputs.home-manager}/modules/services/tldr-update.nix"
      ];

      home.packages = with pkgs; [
        sd
        tlrc
        (if pkgs.stdenv.hostPlatform.isDarwin then darwin.trash else trashy)
      ];
      programs = {
        bat = {
          enable = true;
          config.theme = "base16";
        };
        bottom.enable = true;
        eza = {
          enable = true;
          icons = "auto";
        };
        fd.enable = true;
        fzf = {
          enable = true;
          historyWidget.zsh.command = "";
        };
        mcfly.enable = true;
        pay-respects = {
          enable = true;
          options = [
            "--nocnf"
            "--alias"
          ];
        };
        ripgrep.enable = true;
        zoxide.enable = true;
      };
      services.tldr-update = {
        enable = true;
        package = pkgs.tlrc;
      };
    };
}
