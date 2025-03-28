{ lib, config, pkgs, ... }:
let
  cfg = config.my.jankyborders;
  rice = config.rice;
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
          "active_color=0xff${toString rice.border.active}"
          "inactive_color=0xff${toString rice.border.inactive}"
          "width=${toString rice.border.width}"
        ];
        KeepAlive = true;
      };
    };
  };
}
