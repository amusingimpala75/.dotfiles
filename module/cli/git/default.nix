{ lib, config, pkgs, username, userSettings, ...}:

{
  programs.git = {
    delta.enable = true;
    enable = true;
    ignores = [
      "*~"
      "**/.DS_Store"
    ];
    userEmail = userSettings.git-email;
    userName = userSettings.git-username;
    extraConfig = {
      branch.sort = "-committerdate";
      column.ui = "auto";
      commit.verbose = true;
      diff = {
        algorithm = "histogram";
        renames = true;
      };
      help.autocorrect = "prompt";
      init.defaultBranch = "master";
      tag.sort = "version:refname";
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
