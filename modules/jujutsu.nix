{
  lib,
  self,
  ...
}:
{
  flake.modules.homeManager.jujutsu =
    {
      config,
      ...
    }:
    {
      imports = [ self.wrappers.jujutsu-weave.install ];
      wrappers.jujutsu-weave = {
        enable = true;
        settings.user = {
          name = config.vcs.username;
          email = config.vcs.email;
        };
      };
      # for other's signatures
      programs.gpg.enable = true;
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
            get-change-ids = [
              "log"
              "-G"
              "-T"
              "change_id.short() ++ '\n'"
              "-r"
            ];
          };
          fsmonitor.backend = "watchman";
          git.private-commits = "visible_heads()";
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
            pager = lib.getExe self.packages.${pkgs.stdenv.hostPlatform.system}.delta;
            show-cryptographic-signatures = true;
          };
          working-copy.eol-conversion = "input";
        };

        env.GIT_CONFIG_GLOBAL = pkgs.writeText "jj-git-config" ''
          [core]
            excludesFile = ${self.packages.${pkgs.stdenv.hostPlatform.system}.global-gitignore}
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
            program = lib.getExe' self.packages.${pkgs.stdenv.hostPlatform.system}.weave "weave-driver";
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
