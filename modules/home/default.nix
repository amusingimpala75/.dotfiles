{ pkgs, username, ... }:
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
    home.username = username;
    home.homeDirectory = if stdenv.isDarwin then "/Users/${username}"
    else "/home/${username}";
    home.stateVersion = "24.05"; # Kept for backwards compatibility

    programs.home-manager.enable = true;

    news.display = "silent";
  };
}
