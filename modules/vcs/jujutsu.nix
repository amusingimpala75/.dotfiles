{
  lib,
  self,
  ...
}:
{
  flake.modules.homeManager.jujutsu =
    {
      pkgs,
      ...
    }:
    {
      home.packages = [ pkgs.custom-jujutsu ];
    };

  flake.wrappers = {
    jujutsu =
      {
        pkgs,
        wlib,
        ...
      }:
      {
        imports = [ wlib.wrapperModules.jujutsu ];
        settings = {
          aliases = {
            push-all = [
              "git"
              "push"
              "--remote"
              "*"
            ];
            get-change-ids = [
              "log"
              "-G"
              "-T"
              "change_id.short() ++ '\n'"
              "-r"
            ];
            clean-push = [
              "util"
              "exec"
              "--"
              "sh"
              "-c"
              "jj run -j 4 -- pre-commit run --all-files && jj git push"
            ];
          };
          git.private-commits = "visible_heads() | description('private:*')";
          merge-tools.delta.diff-expected-exit-codes = [
            0
            1
          ];
          revsets = {
            bookmark-advance-to = "@-";
          };
          signing = {
            backend = "ssh";
            key = "~/.ssh/id_ed25519.pub";
            behavior = "drop";
          };
          git.sign-on-push = true;
          ui = {
            default-command = "log";
            diff-editor = ":builtin";
            diff-formatter = ":git";
            pager = lib.getExe pkgs.custom-delta;
            show-cryptographic-signatures = true;
          };
          user = {
            email = "git@amusingimpala.com";
            name = "amusingimpala75";
          };
          working-copy.eol-conversion = "input";
        };

        runtimePkgs = [ pkgs.gnupg ];

        env.GIT_CONFIG_GLOBAL = pkgs.writeText "jj-git-config" ''
          [core]
            excludesFile = ${pkgs.global-gitignore}
        '';
      };

    jujutsu-weave =
      {
        pkgs,
        ...
      }:
      {
        imports = [ self.wrapperModules.jujutsu ];
        settings = {
          merge-tools.weave = {
            program = lib.getExe' pkgs.weave "weave-driver";
            merge-args = [
              "$base"
              "$left"
              "$right"
              "-o"
              "$output"
              "-l"
              "$marker_length"
              "-p"
              "$path"
            ];
            merge-conflict-exit-codes = [ 1 ];
            merge-tool-edits-conflict-markers = true;
            conflict-marker-style = "git";
          };
          ui.merge-editor = "weave";
        };
      };
  };
}
