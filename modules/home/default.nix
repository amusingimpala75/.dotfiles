{ config, pkgs, self, ... }:
let
  stdenv = pkgs.stdenv;
in
{
  imports = with self.modules.homeManager; with self.modules.generic; [
    nixpkgs
    nix

    ./alacritty
    ./bat
    ./cli
    ./darwin
    ./direnv
    ./emacs
    ./firefox
    # ./fish
    ./games
    ./ghostty
    ./nix
    # ./nushell
    ./rice
    ./sops
    ./spotify
    ./starship
    ./vcs
    ./wezterm
    ./wsl
    ./zsh
  ];

  config = {
    home.homeDirectory =
      if stdenv.isDarwin then "/Users/${config.home.username}" else "/home/${config.home.username}";
    home.stateVersion = "24.05"; # Kept for backwards compatibility

    programs.home-manager.enable = true;

    news.display = "silent";
  };
}
