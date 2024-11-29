{ lib, config, pkgs, userSettings, ... }: let
  formatScript = path: pkgs.substituteAll {
    src = path;
    isExecutable = true;

    sketchybar = "${pkgs.sketchybar}/bin/sketchybar";
    bash = "${pkgs.bash}/bin/bash";
  };
in {
  home.packages = pkgs.lib.mkIf pkgs.stdenv.isDarwin [ pkgs.sketchybar ];

  home.file.".config/sketchybar/sketchybarrc".source = lib.mkIf pkgs.stdenv.isDarwin (
    pkgs.substituteAll {
      src = ./sketchybarrc;
      isExecutable = true;

      sketchybar = "${pkgs.sketchybar}/bin/sketchybar";
      bash = "${pkgs.bash}/bin/bash";

      "bar_position" = if userSettings.bar.isTop then "top" else "bottom";
      "bar_height" = userSettings.bar.height;
      "bar_color" = userSettings.bar.color;

      "font_family" = userSettings.font.family.fixed-pitch;
      "font_size" = userSettings.font.size;
      "text_color" = userSettings.theme.base05;

      "front_app_script" = (formatScript ./front_app.sh);
    }
  );

  launchd.agents."sketchybar" = {
    enable = true;
    config = rec {
      KeepAlive = true;
      Program = "${pkgs.sketchybar}/bin/sketchybar";
      ProgramArguments = [
        Program
      ];
    };
  };

  home.activation."sketchybar" = lib.mkIf pkgs.stdenv.isDarwin (
    lib.hm.dag.entryAfter [ "setupLaunchAgents" "onFilesChange" "installPackages" ] ''
      ${pkgs.sketchybar}/bin/sketchybar --reload
    ''
  );
}
