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
      enable = true;
      ignores = [
        "*~"
        "**/.DS_Store"
        ".direnv"
        ".envrc"
      ];
      settings = {
        branch.sort = "-committerdate";
        column.ui = "auto";
        commit.verbose = true;
        diff = {
          algorithm = "histogram";
          renames = true;
        };
        help.autocorrect = "prompt";
        init.defaultBranch = "master";
        push.autoSetupRemote = true;
        tag.sort = "version:refname";
        user = {
          email = lib.mkIf (cfg.email != null) cfg.email;
          name = lib.mkIf (cfg.username != null) cfg.username;
        };
      };
    };

    programs.delta = {
      enable = true;
      enableGitIntegration = true;
    };

    programs.git-credential-oauth.enable = true;

    home.packages = [
      pkgs.github-cli
    ];
  };
}
