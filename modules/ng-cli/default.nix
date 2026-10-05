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
        "${inputs.home-manager}/modules/programs/direnv.nix"
        "${inputs.home-manager}/modules/programs/eza.nix"
        "${inputs.home-manager}/modules/programs/fzf.nix"
        "${inputs.home-manager}/modules/programs/git.nix" # for direnv.nix
        "${inputs.home-manager}/modules/programs/mcfly.nix"
        "${inputs.home-manager}/modules/programs/pay-respects.nix"
        "${inputs.home-manager}/modules/programs/zoxide.nix"
        "${inputs.home-manager}/modules/services/tldr-update.nix"
      ];

      home.packages = with pkgs; [
        custom-bottom
        custom-bat
        fd
        ripgrep
        sd
        tlrc
        (if pkgs.stdenv.hostPlatform.isDarwin then darwin.trash else trashy)
        ncdu
      ];
      programs = {
        eza = {
          enable = true;
          icons = "auto";
        };
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
        zoxide.enable = true;
      };
      services.tldr-update = {
        enable = true;
        package = pkgs.tlrc;
      };
    };
}
