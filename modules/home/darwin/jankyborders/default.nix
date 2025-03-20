{ lib, config, pkgs, userSettings, ... }:
let
  cfg = config.my.jankyborders;
  stdenv = pkgs.stdenv;
in {
  options.my.jankyborders = {
    enable = lib.mkEnableOption "my janky borders configuration";
  };

  config = lib.mkIf (cfg.enable && stdenv.isDarwin) {
    launchd.agents."jankyborders" = {
      enable = true;
      config = rec {
        Program = "${pkgs.jankyborders}/bin/borders";
        ProgramArguments = [
          Program
          "style=square"
          "active_color=0xff${toString userSettings.border.active}"
          "inactive_color=0xff${toString userSettings.border.inactive}"
          "width=${toString userSettings.border.width}"
        ];
        KeepAlive = true;
      };
    };
  };
}
