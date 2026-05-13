{
  flake.modules.homeManager.git =
    {
      config,
      ...
    }:
    {
      programs = {
        git = {
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
              email = config.vcs.email;
              name = config.vcs.username;
            };
          };
          signing.format = "ssh";
        };

        delta = {
          enable = true;
          enableGitIntegration = true;
        };

        git-credential-oauth.enable = true;
      };

      programs.gh = {
        enable = true;
        settings = {
          git_protocol = "ssh";
          telemetry = "disabled";
        };
      };
    };
}
