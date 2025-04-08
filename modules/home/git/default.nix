{ lib, config, pkgs, ...}:
let
  cfg = config.my.git;
in {
  options = {
    my.git = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        example = true;
        description = "Enable custom git configuration";
      };
      email = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        example = "foo@bar.com";
        description = "Email to use for git";
      };
      username = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        example = "johndoe";
        description = "Git username";
      };
    };
  };
  config = lib.mkIf cfg.enable {
    programs.git = {
      delta.enable = true;
      enable = true;
      ignores = [
        "*~"
        "**/.DS_Store"
        ".direnv"
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

    home.shellAliases = {
      gcm = "git commit -m";
      ga = "git add";
      gap = "git add --patch";
      gs = "git status";
      gd = "git diff";
      gl = "git log";
    };
  };
}
