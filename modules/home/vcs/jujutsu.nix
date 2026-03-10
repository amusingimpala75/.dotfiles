{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.my.vcs;
  package = inputs.nixpkgs-jj37.legacyPackages.${pkgs.stdenv.hostPlatform.system}.jujutsu;
in
{
  options.my.vcs.jujutsu = lib.mkEnableOption "jujutsu configuration";

  config = lib.mkIf cfg.jujutsu {
    nixpkgs.overlays = [
      (final: prev: {
        # Thanks for not having a proper overlay smh
        jj-spr = inputs.jj-spr.packages.${final.stdenv.hostPlatform.system}.default.overrideAttrs (old: {
          nativeBuildInputs =
            old.nativeBuildInputs |> lib.filter (pkg: pkg != prev.jujutsu) |> (list: list ++ [ package ]);
        });
      })
    ];
    programs.jujutsu = {
      enable = true;
      inherit package;
      settings = {
        aliases = {
          extend-feature = [
            "util"
            "exec"
            "--"
            "sh"
            "-c"
            ''
              FEATURE_BASE="$1"
              shift
              jj new --insert-after "heads(feature_stack($FEATURE_BASE))" "$@"
            ''
            ""
          ];
          land-feature = [
            "util"
            "exec"
            "--"
            "sh"
            "-c"
            ''
              FEATURE_BASE="$1"
              jj log -G -r "feature_stack($FEATURE_BASE)" -T 'change_id.short() ++ "\n"' | tac | while read change; do
                jj spr land -r "$change"
                jj rebase-features
                jj spr diff -r "feature_stack($change)" --all
              done
              jj abandon "feature_stack($FEATURE_BASE)"
              jj edit tip
              # We don't want to keep tip on top of master
              # if there are any more mutable commits between
              # master and tip
              if [ -n "$(jj log -G -r 'parents(tip) & mutable()')" ]
              then
                jj rebase -r tip --onto 'parents(tip) & mutable()'
              fi
            ''
            ""
          ];
          new-feature = [
            "new"
            "--insert-after"
            "guestimate_master()"
            "--insert-before"
            "tip"
          ];
          rebase-features = [
            "rebase"
            "-s"
            "features()"
            "--onto"
            "guestimate_master()"
          ];
          spr = [
            "util"
            "exec"
            "--"
            "jj-spr"
          ];
          spr-diff-feature = [
            "util"
            "exec"
            "--"
            "sh"
            "-c"
            ''
              FEATURE_BASE="$1"
              jj spr diff -r "feature_stack($FEATURE_BASE)" --all
            ''
            ""
          ];
          spr-init-tip = [
            "util"
            "exec"
            "--"
            "sh"
            "-c"
            ''
              jj spr init
              jj new tracked_remote_bookmarks()
              jj bookmark c tip -r heads(tracked_remote_bookmarks())
            ''
            ""
          ];
          tug = [
            "bookmark"
            "move"
            "--from"
            "heads(::@- & bookmarks())"
            "--to"
            "@-"
          ];
        };
        fsmonitor.backend = "watchman";
        git.private-commits = "bookmarks(tip)";
        revset-aliases = {
          "feature_stack(base)" = "base::tip ~ tip";
          "features()" = "roots(::tip & mutable())";
          "guestimate_master()" = "parents(features()):: & tracked_remote_bookmarks()";
        };
        ui.default-command = "log";
        user = {
          name = lib.mkIf (cfg.username != null) cfg.username;
          email = lib.mkIf (cfg.email != null) cfg.email;
        };
        working-copy.eol-conversion = "input";
      };
    };
    home.packages = [ pkgs.jj-spr ];
  };
}
