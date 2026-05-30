{
  lib,
  ...
}:
{
  flake.modules.homeManager.jujutsu =
    {
      config,
      pkgs,
      ...
    }:
    {
      programs.jujutsu = {
        ediff = true;
        enable = true;
        package =
          (pkgs.writeShellScriptBin "jj" ''
            export GIT_CONFIG_GLOBAL=${config.wrappers.custom-git.constructFiles.gitconfig.outPath}
            exec ${lib.getExe pkgs.jujutsu} "$@"
          '')
          // {
            inherit (pkgs.jujutsu) version;
          };
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
            merge-editor = "weave";
            show-cryptographic-signatures = true;
          };
          user = {
            name = config.vcs.username;
            email = config.vcs.email;
          };
          working-copy.eol-conversion = "input";
        };
      };
      programs.delta = {
        enable = true;
        enableJujutsuIntegration = true;
        options.syntax-theme = "ansi";
      };
      home.packages = with pkgs; [
        weave
      ];
      # for other's signatures
      programs.gpg.enable = true;
    };
}
