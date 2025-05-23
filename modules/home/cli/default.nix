{ config, lib, pkgs, ... }:
{
  options.my.cli.enable = lib.mkEnableOption "my cli configuration";

  options.my.cli.defaultShell = lib.mkOption {
    description = "which shell is the default";
  };

  config = lib.mkIf config.my.cli.enable {
    my.bat.enable = true;
    my.direnv.enable = true;
    my.nix.enable = true;
    my.zsh.enable = true;
    my.nushell.enable = true;

    home.packages = with pkgs; [
      (bible.asv.override { grepCommand = "${pkgs.ripgrep}/bin/rg"; })
      chafa
      fd
      fzf
      ripgrep
      scc
      tealdeer
      tree
    ];

    home.shellAliases = {
      ll = "ls -lah";
      img = "chafa";
      scc = "scc --no-cocomo";
    };
  };
}
