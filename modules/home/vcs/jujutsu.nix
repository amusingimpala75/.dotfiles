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
