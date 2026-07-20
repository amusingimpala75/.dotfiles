{
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
        self.wrappers.gh.install
        self.wrappers.custom-git.install
      ];

      home.packages = [ pkgs.git-remote-setup ];

      wrappers = {
        custom-git = {
          enable = true;
          settings.user = {
            email = config.vcs.email;
            name = config.vcs.username;
          };
        };

        gh.enable = true;
      };
    };

  flake.wrappers = {
    custom-git =
      {
        lib,
        pkgs,
        wlib,
        ...
      }:
      {
        imports = [ wlib.wrapperModules.git ];
        settings = {
          branch.sort = "-comitterdate";
          column.ui = "auto";
          commit.verbose = true;
          core.excludesFile = self.packages.${pkgs.stdenv.hostPlatform.system}.global-gitignore;
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
              path = lib.getExe self.packages.${pkgs.stdenv.hostPlatform.system}.delta;
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

    gh = {
      imports = [ self.wrapperModules.gh-wrapper ];

      settings = {
        git_protocol = "ssh";
        telemetry = "disabled";
        version = "1";
      };
    };

    gh-wrapper =
      {
        config,
        lib,
        pkgs,
        wlib,
        ...
      }:
      {
        imports = [ wlib.modules.default ];

        options.settings = lib.mkOption {
          type = wlib.types.structuredValueWith {
            nullable = false;
            typeName = "JSON";
          };
          default = { };
        };

        config = {
          package = pkgs.gh;
          env.GH_CONFIG_DIR = dirOf config.constructFiles.generatedConfig.path;
          constructFiles.generatedConfig = {
            content = builtins.toJSON config.settings;
            relPath = "config/config.yml";
            builder = ''${lib.getExe' pkgs.remarshal "json2yaml"} "$1" "$2"'';
          };
        };
      };
  };

  perSystem.wrappers.packages.gh-wrapper = true;
}
