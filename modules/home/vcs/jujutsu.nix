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
          mergiraf = [
            "resolve"
            "--tool"
            "mergiraf"
          ];
          split-new = [
            "new"
            "--insert-before"
            "@"
            "--no-edit"
          ];
          sem = [
            "util"
            "exec"
            "--"
            "sem"
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
          weave = [
            "resolve"
            "--tool"
            "weave"
          ];
        };
        fsmonitor.backend = "watchman";
        git.private-commits = "bookmarks(tip)";
        merge-tools.weave = {
          program = "weave-driver";
          merge-args = ["$base" "$left" "$right" "-o" "$output" "-l" "$marker_length" "-p" "$path"];
          merge-conflict-exit-codes = [1];
          merge-tool-edits-conflict-markers = true;
          conflict-marker-style = "git";
        };
        revset-aliases = {
          "feature_base(id)" = "::id & features()";
          "feature_stack(id)" = "feature_base(id)::tip-";
          "features()" = "roots(::tip & mutable())";
          "guestimate_master()" = "parents(features()):: & tracked_remote_bookmarks()";
        };
        signing = {
          backend = "ssh";
          key = "~/.ssh/id_ed25519.pub";
          behavior = "own";
        };
        ui = {
          default-command = "log";
          show-cryptographic-signatures = true;
        };
        user = {
          name = lib.mkIf (cfg.username != null) cfg.username;
          email = lib.mkIf (cfg.email != null) cfg.email;
        };
        working-copy.eol-conversion = "input";
      };
    };
    home.packages = with pkgs; [
      jj-spr
      mergiraf
      sem-diff
      weave
    ];
    # for other's signatures
    programs.gpg.enable = true;
  };
}
