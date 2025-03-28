{ pkgs, config, ... }:
let
  stdenv = pkgs.stdenv;
in {
  imports = [
    ./alacritty
    ./bat
    ./darwin
    ./direnv
    ./emacs
    ./firefox
    ./ghostty
    ./git
    ./nix
    ./spotify
    ./theme
    ./zsh
  ];

  config = {
    home.homeDirectory = if stdenv.isDarwin then "/Users/${config.home.username}"
    else "/home/${config.home.username}";
    home.stateVersion = "24.05"; # Kept for backwards compatibility

    programs.home-manager.enable = true;

    news.display = "silent";
  };
}
