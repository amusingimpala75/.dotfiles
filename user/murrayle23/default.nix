{ lib, config, pkgs, username, hostname, dotfilesDir, userSettings, ... }:

# TODO: add wallpaper (both with nix-wallpaper,
#       and with some custom way to set the Index.plist
{
  home.username = username;
  home.homeDirectory = "/home/${username}";
  home.stateVersion = "24.05"; # Don't change; kept for backwards compatibility reasons.

  programs.home-manager.enable = true;

  imports = [
    ../../module/home
    ../../module/app/emacs
    ../../module/app/firefox
    ../../module/font
    ../../module/theme
  ];

  home.packages = with pkgs; [
    (bible.asv.override { grepCommand = "${pkgs.ripgrep}/bin/rg"; })
    fastfetch
    fd
    ripgrep
    scc
    tree
    yq-go
  ];

  my.direnv.enable = true;

  my.git = {
    enable = true;
    email = "69653100+amusingimpala75@users.noreply.github.com";
    username = "amusingimpala75";
  };

  my.nix.enable = true;

  my.zsh.enable = true;

  theme = userSettings.theme; # TODO import directly here after we banish userSettings

  news.display = "silent";

  home.shellAliases = {
    ll = "ls -lah";
  };
}
