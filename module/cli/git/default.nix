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
    extraConfig = {
      init.defaultBranch = "master";
    };
  };

  programs.git-credential-oauth.enable = true;

  home.packages = [
    pkgs.github-cli
  ];

  home.shellAliases = {
    gcm = "git commit -m";
    ga = "git add";
    gap = "git add --patch";
    gs = "git status";
    gd = "git diff";
    gl = "git log";
  };
}
