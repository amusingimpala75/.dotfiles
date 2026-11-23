{
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
            fetch-rebase = [
              "util"
              "exec"
              "--"
              "sh"
              "-c"
              ''
                old_trunk=$(jj get-change-ids 'trunk()')
                jj git fetch
                jj rebase -s "$old_trunk+ & mutable()" --onto 'trunk()'
              ''
            ];
            get-change-ids = [
              "log"
              "-G"
              "-T"
              "change_id.short() ++ '\n'"
              "-r"
            ];
            watch = [
              "util"
              "exec"
              "--"
              "sh"
              "-c"
              "viddy -t -n 1 jj log --color=always --ignore-working-copy"
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
          templates = {
            git_push_bookmark = ''"amusingimpala/" ++ description.first_line().lower().replace(regex:"[^a-z0-9]", "-").trim() ++ "-" ++ change_id.short()'';
          };
          ui = {
            default-command = "log";
            diff-editor = ":builtin";
            diff-formatter = ":git";
            pager = "delta";
            show-cryptographic-signatures = true;
          };
          user = {
            email = "git@amusingimpala.com";
            name = "amusingimpala75";
          };
          working-copy.eol-conversion = "input";
        };

        runtimePkgs = with pkgs; [
          custom-delta
          gnupg
          viddy
        ];

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
            program = "weave-driver";
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

        runtimePkgs = [ pkgs.weave ];
      };
  };
}
