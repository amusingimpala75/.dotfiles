{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:
{
  imports = [
    ./tmux.nix
  ];

  options.my.cli.enable = lib.mkEnableOption "my cli configuration";

  config = lib.mkIf config.my.cli.enable {
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
