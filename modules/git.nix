{
  inputs,
  self,
  ...
}:
{
  flake.modules.homeManager.git =
    {
      config,
      pkgs,
      ...
    }:
    {
      imports = [
        self.wrappers.git.install
        "${inputs.home-manager}/modules/programs/gh.nix"
      ];

      home.packages = with pkgs; [
        git-remote-setup
      ];

      programs.gh = {
        enable = true;
        settings = {
          git_protocol = "ssh";
          telemetry = "disabled";
          version = "1";
        };
        extensions = with pkgs; [
          gh-contribs
          gh-dash
          gh-enhance
          gh-notify
          gh-skyline
          gh-stack
          gh-yule-log
        ];
      };

      wrappers = {
        git = {
          enable = true;
          settings.user = {
            email = config.vcs.email;
            name = config.vcs.username;
          };
        };
      };
    };

  flake.wrappers = {
    git =
      {
        lib,
        pkgs,
        wlib,
        ...
      }:
      {
        imports = [ wlib.wrapperModules.git ];
        settings = {
          branch.sort = "-committerdate";
          column.ui = "auto";
          commit.verbose = true;
          core.excludesFile = pkgs.global-gitignore;
          credential.helper = lib.getExe pkgs.git-credential-oauth;
          credential."https://github.com".helper = "${lib.getExe pkgs.gh} auth git-credential";
          delta.syntax-theme = "ansi";
          diff = {
            algorithm = "histogram";
            renames = true;
          };
          gpg.format = "ssh";
          gpg.ssh.program = lib.getExe' pkgs.openssh "ssh-keygen";
          help.autocorrect = "prompt";
          init.defaultBranch = "trunk";
          interactive.diffFilter = "${lib.getExe pkgs.delta} --color-only";
          pager =
            let
              path = lib.getExe pkgs.custom-delta;
            in
            {
              blame = path;
              diff = path;
              log = path;
              show = path;
            };
          push.autoSetupRemote = true;
          tag.sort = "version:refname";
          # Get username and email from further wrapping
        };
      };
  };
}
