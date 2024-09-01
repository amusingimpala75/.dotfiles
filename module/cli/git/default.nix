{ lib, config, pkgs, username, userSettings, ...}:

{
  programs.git = {
    enable = true;
    ignores = [
      "*~"
      "**/.DS_Store"
    ];
    userEmail = userSettings.git-email;
    userName = userSettings.git-username;
  };

  home.packages = [
    pkgs.github-cli
  ];

  home.shellAliases = {
    gcm = "git commit -m";
    ga = "git add";
    gs = "git status";
    gd = "git diff";
  };
}
