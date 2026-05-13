{
  flake.modules.homeManager.ghostty =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    {
      programs.ghostty = {
        enable = true;
        package = if pkgs.stdenv.isLinux then pkgs.ghostty else pkgs.ghostty-bin;
        settings = with config.rice; {
          background-opacity = "${toString opacity}";
          background-blur-radius = 10;

          selection-invert-fg-bg = true;
          window-theme = "system";

          font-family = "${toString font.family.fixed-pitch}";
          font-thicken = true;
          font-size = "${toString font.size}";

          mouse-hide-while-typing = true;
          cursor-style = "block";
          shell-integration-features = "no-cursor";

          quit-after-last-window-closed = true;

          macos-titlebar-style = "hidden";
          macos-option-as-alt = true;

          command = "zsh";

          auto-update = "off";

          theme = "wallust";
        };
      };

      home.file.".hushlogin".text = lib.mkIf pkgs.stdenv.isDarwin "";
    };
}
