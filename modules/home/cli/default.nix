{
  config,
  inputs,
  lib,
  pkgs,
  self,
  ...
}:
{
  imports = [
    self.modules.homeManager.direnv
    ./tmux.nix
  ];

  options.my.cli.enable = lib.mkEnableOption "my cli configuration";

  options.my.cli.defaultShell = lib.mkOption {
    description = "which shell is the default";
  };

  config = lib.mkIf config.my.cli.enable {
    my = {
      nix.enable = true;
      zsh.enable = true;
    };

    nixpkgs.overlays = [ inputs.bible.overlays.default ];

    home.packages = with pkgs; [
      bible.asv
      chafa
      doxx
      file
      jaq
      killall
      scc
      tree
      up
    ];
  };
}
