{
  config,
  inputs,
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
    my = {
      bat.enable = true;
      direnv.enable = true;
      nix.enable = true;
      zsh.enable = true;
    };

    nixpkgs.overlays = [ inputs.bible.overlays.default ];

    home.packages = with pkgs; [
      bible.asv
      chafa
      file
      jaq
      killall
      scc
      sd
      tree
    ];

    programs = {
      eza = {
        enable = true;
        icons = "always";
      };
      fd.enable = true;
      fzf.enable = true;
      ripgrep.enable = true;
      tealdeer = {
        enable = true;
        enableAutoUpdates = false;
      };
      zoxide.enable = true;
    };
  };
}
