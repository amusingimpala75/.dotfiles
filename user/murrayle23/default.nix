{ lib, config, pkgs, username, hostname, dotfilesDir, userSettings, ... }:

# TODO: add wallpaper (both with nix-wallpaper,
#       and with some custom way to set the Index.plist
{
  home.username = username;
  home.homeDirectory = "/home/${username}";
  home.stateVersion = "24.05"; # Don't change; kept for backwards compatibility reasons.

  programs.home-manager.enable = true;

  imports = [
    # ../../module/app/alacritty
    ../../module/app/emacs
    # ../../module/app/firefox
    ../../module/cli/git
    ../../module/cli/nix
    ../../module/cli/zsh
    ../../module/font
    ../../module/theme
  ];

  home.packages = with pkgs; [
    fastfetch
    scc
    tree
    yq-go
  ];

  news.display = "silent";

  home.shellAliases = {
    ll = "ls -lah";
  };
}
