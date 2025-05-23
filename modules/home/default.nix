{ pkgs, config, ... }:
let
  stdenv = pkgs.stdenv;
in {
  imports = [
    ./alacritty
    ./bat
    ./cli
    ./darwin
    ./direnv
    ./emacs
    ./firefox
    ./games
    ./ghostty
    ./git
    ./nix
    ./nushell
    ./rice
    ../shared
    ./spotify
    ./wezterm
    ./wsl
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
