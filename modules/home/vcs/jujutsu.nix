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
          # The feature workflow requires write access as it
          # depends on jj-spr. It goes something like this:
          # - If this is a new repo, clone with jj git clone
          # - If not a new repo, make sure there is only one
          #   change on top of master, and it /should/ be empty
          #   although that does not matter for this tool.
          # - To set up the workflow, run and follow the prompts:
          #   jj init-feature-workflow
          # - To create a new feature at any point, run
          #   jj new-feature [any 'jj new' flags besides --insert-<after|before>]
          # - Squash some changes from tip into that change or
          #   edit directly, doesn't matter.
          # - To add another change to the feature, making
          #   it a stacked pr, run
          #   jj extend-feature [some change-id in the feature stack] [same options as new-feature]
          # - To update PRs for the changes on github, run
          #   jj update-feature [some change id in the feature stack]
          # - To land PR for a feature, run
          #   jj land-feature [some change id in the feature stack]
          #   and this will take care of doing the stack correctly
          # - If you get out of sync with master because others
          #   are committing to master, rebase all features back on master with:
          #   jj rebase-features
          extend-feature = [
            "util"
            "exec"
            "--"
            "sh"
            "-c"
            ''
              CHANGE_ID="$1"
              shift
              jj new --insert-after "heads(feature_stack($CHANGE_ID))" "$@"
            ''
            ""
          ];
          init-feature-workflow = [
            "util"
            "exec"
            "--"
            "sh"
            "-c"
            ''
              jj git colocation enable
              jj spr init
              jj bookmark c tip -r 'heads(tracked_remote_bookmarks()::)'
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
              CHANGE_ID="$1"
              set -e
              jj log -G -r "feature_stack($CHANGE_ID)" -T 'change_id.short() ++ "\n"' | tac | while read change; do
                jj update-feature "$change" -m "merging stack"
                printf "Press ENTER after reapproval" > /dev/tty
                read _ < /dev/tty
                jj spr land -r "$change"
                jj rebase-features
                jj abandon "$change"
              done
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
          tug = [
            "bookmark"
            "move"
            "--from"
            "heads(::@- & bookmarks())"
            "--to"
            "@-"
          ];
          update-feature = [
            "util"
            "exec"
            "--"
            "sh"
            "-c"
            ''
              CHANGE_ID="$1"
              shift
              jj spr diff -r "feature_stack($CHANGE_ID)" --all "$@"
            ''
            ""
          ];
        };
        fsmonitor.backend = "watchman";
        git.private-commits = "bookmarks(tip)";
        revset-aliases = {
          "feature_base(id)" = "::id & features()";
          "feature_stack(id)" = "feature_base(id)::tip-";
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
