{
  flake.wrappers.git =
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
        user = {
          email = "git@amusingimpala.com";
          name = "amusingimpala75";
        };
      };
    };
}
