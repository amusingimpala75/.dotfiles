{
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.my.vcs;
in
{
  options.my.vcs.jujutsu = lib.mkEnableOption "jujutsu configuration";

  config = lib.mkIf cfg.jujutsu {
    programs.jujutsu = {
      enable = true;
      settings = {
        user = {
          name = lib.mkIf (cfg.username != null) cfg.username;
          email = lib.mkIf (cfg.email != null) cfg.email;
        };
        fsmonitor.backend = "watchman";
        working-copy.eol-conversion = "input";
      };
    };
  };
}
