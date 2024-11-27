{ lib, config, pkgs, userSettings, ... }:
{
  home.packages = pkgs.lib.mkIf pkgs.stdenv.isDarwin [ pkgs.jankyborders ];

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
}
