{ lib, config, pkgs, username, ...}:

{
  programs.git = {
    enable = true;
    ignores = [
      "*~"
      "**/.DS_Store"
    ];
  };

  home.shellAliases = {
    gcm = "git commit -m";
    ga = "git add";
    gs = "git status";
    gd = "git diff";
  };
}