{
  inputs,
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
      nixpkgs.overlays = [
        (final: _: {
          jj-spr = inputs.jj-spr.packages.${final.stdenv.hostPlatform.system}.default;
        })
      ];
      programs.jujutsu = {
        ediff = true;
        enable = true;
        settings = {
          aliases = {
            features = [
              "util"
              "exec"
              "--"
              "sh"
              "${./jj-features.sh}"
            ];
            get-change-ids = [
              "log"
              "-G"
              "-T"
              "change_id.short() ++ '\n'"
              "-r"
            ];
            spr = [
              "util"
              "exec"
              "--"
              "jj-spr"
            ];
          };
          fsmonitor.backend = "watchman";
          git.private-commits = "bookmarks(tip)";
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
          revset-aliases = {
            "feature_base(id)" = "::id & features()";
            "feature_stack(id)" = "feature_base(id)::tip-";
            "features()" = "roots(::tip & mutable())";
            "guestimate_master()" = "parents(features()):: & tracked_remote_bookmarks()";
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
        jj-spr
        weave
      ];
      # for other's signatures
      programs.gpg.enable = true;
      # since we rely on git colocation
      programs.git.enable = true;
    };

  flake-file.inputs.jj-spr = {
    url = "github:amusingimpala75/jj-spr/fix-nix-jj-38";
    inputs.nixpkgs.follows = "nixpkgs";
  };
}
