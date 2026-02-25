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
          nativeBuildInputs = old.nativeBuildInputs
            |> lib.filter (pkg: pkg != prev.jujutsu)
            |> (list: list ++ [ package ]);
        });
      })
    ];
    programs.jujutsu = {
      enable = true;
      inherit package;
      settings = {
        aliases = {
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
        git.colocate = false;
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
