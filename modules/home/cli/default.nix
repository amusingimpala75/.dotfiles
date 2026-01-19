{
  config,
  lib,
  pkgs,
  ...
}:
{
  imports = [
    ./opencode.nix
    ./tmux.nix
  ];

  options.my.cli.enable = lib.mkEnableOption "my cli configuration";

  options.my.cli.defaultShell = lib.mkOption {
    description = "which shell is the default";
  };

  config = lib.mkIf config.my.cli.enable {
    my.bat.enable = true;
    my.direnv.enable = true;
    my.nix.enable = true;
    my.tmux.enable = true;
    my.zsh.enable = true;

    home.packages = with pkgs; [
      (bible.asv.override { grepCommand = "${pkgs.ripgrep}/bin/rg"; })
      chafa
      killall
      scc
      tree
    ];

    programs.eza = {
      enable = true;
      icons = "always";
    };
    programs.fd.enable = true;
    programs.fzf.enable = true;
    programs.ripgrep.enable = true;
    programs.tealdeer = {
      enable = true;
      enableAutoUpdates = false;
    };
    programs.zoxide.enable = true;
  };
}
