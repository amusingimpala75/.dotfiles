{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.my.vcs;
in
{
  options.my.vcs.jujutsu = lib.mkEnableOption "jujutsu configuration";

  config = lib.mkIf cfg.jujutsu {
    nixpkgs.overlays = [
      (final: _: {
        jj-spr = inputs.jj-spr.packages.${final.stdenv.hostPlatform.system}.default;
      })
    ];
    programs.jujutsu = {
      enable = true;
      settings = {
        aliases.spr = [ "util" "exec" "--" "jj-spr" ];
        fsmonitor.backend = "watchman";
        revsets.log = "all()";
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
