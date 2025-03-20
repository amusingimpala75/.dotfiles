{ pkgs, username, ... }:
let
  stdenv = pkgs.stdenv;
in {
  imports = [
    ./alacritty
    ./bat
    ./direnv
    ./emacs
    ./firefox
    ./ghostty
    ./git
    ./nix
    ./spotify
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
