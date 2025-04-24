{ config, lib, pkgs, ... }:
{
  options.my.cli.enable = lib.mkEnableOption "my cli configuration";

  config = lib.mkIf config.my.cli.enable {
    my.bat.enable = true;
    my.direnv.enable = true;
    my.nix.enable = true;
    my.zsh.enable = true;

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
