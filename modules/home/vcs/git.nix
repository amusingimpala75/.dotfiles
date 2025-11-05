{
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.my.vcs;
in
{
  options.my.vcs.git = lib.mkEnableOption "custom git configuration";

  config = lib.mkIf cfg.git {
    programs.git = {
      delta.enable = true;
      enable = true;
      ignores = [
        "*~"
        "**/.DS_Store"
        ".direnv"
        ".envrc"
      ];
      userEmail = lib.mkIf (cfg.email != null) cfg.email;
      userName = lib.mkIf (cfg.username != null) cfg.username;
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
  };
}
