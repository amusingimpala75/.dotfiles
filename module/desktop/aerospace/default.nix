{ lib, config, pkgs, userSettings, ... }:
{
  home.packages = pkgs.lib.mkIf pkgs.stdenv.isDarwin [ pkgs.aerospace ];

  home.file.".config/aerospace/aerospace.toml".source = lib.mkIf pkgs.stdenv.isDarwin (
    pkgs.substituteAll {
      src = ./aerospace.toml;

      sketchybar = "${pkgs.sketchybar}/bin/sketchybar";
      bash = "${pkgs.bash}/bin/bash";

      "inner_gap" = "${toString (userSettings.gaps.inner * 2)}";
      "outer_gap" = "${toString (userSettings.gaps.outer)}";
      "outer_gap_top" = "${toString (userSettings.gaps.outer + userSettings.bar.height)}";
      "outer_gap_bottom" = "${toString (userSettings.gaps.outer - 1)}";
    }
  );

  launchd.agents."aerospace" = {
    enable = true;
    config = rec {
      Program = "/usr/bin/open";
      ProgramArguments = [
        Program
        "-a"
        "AeroSpace"
      ];
      KeepAlive = false;
    };
  };

  home.activation."aerospace" = lib.mkIf pkgs.stdenv.isDarwin (
    lib.hm.dag.entryAfter [ "setupLaunchAgents" "onFilesChange" "installPackages"] ''
      ${pkgs.aerospace}/bin/aerospace reload-config
    ''
  );
}