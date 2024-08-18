{ lib, config, pkgs, username, ...}:

{
  programs.git = {
    enable = true;
    ignores = [
      "*~"
      "**/.DS_Store"
    ];
  };
}