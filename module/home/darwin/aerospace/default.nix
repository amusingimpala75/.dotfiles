{ lib, config, pkgs, userSettings, ... }:
let
  cfg = config.my.aerospace;
  stdenv = pkgs.stdenv;

  aerospace = "${pkgs.aerospace}/bin/aerospace";
  bash = "${pkgs.bash}/bin/bash";
  btop = "${pkgs.btop}/bin/btop";
  float_and = "${pkgs.float_and}/bin/float_and";
  ghostty_and = "${pkgs.ghostty_and}/bin/ghostty_and";
  launcher = "${pkgs.my.launcher}/bin/launcher";
  sketchybar = "${pkgs.sketchybar}/bin/sketchybar";
in {
  options.my.aerospace = {
    enable = lib.mkEnableOption "my aerospace config";
  };

  config = lib.mkIf (cfg.enable && stdenv.isDarwin) {
    programs.aerospace = {
      enable = true;

      userSettings = {
        after-startup-command = [ "exec-and-forget ${sketchybar}" ];
        exec-on-workspace-change = [
          "${bash}"
          "-c"
          "${sketchybar} --trigger aerospace_workspace_change FOCUSED_WORKSPACE=$AEROSPACE_FOCUSED_WORKSPACE"
        ];
        start-at-login = true;
        enable-normalization-flatten-containers = true;
        enable-normalization-opposite-orientation-for-nested-containers = true;

        accordion-padding = 30;
        default-root-container-layout = "tiles";
        default-root-container-orientation = "auto";

        key-mapping.preset = "qwerty";

        on-focused-monitor-changed = [ "move-mouse monitor-lazy-center" ];

        gaps = let
          inner = userSettings.gaps.inner * 2;
          outer = userSettings.gaps.outer;
          outer-top = userSettings.gaps.outer + userSettings.bar.height;
          outer-bottom = userSettings.gaps.outer - 1;
        in {
          inner.horizontal = inner;
          inner.vertical = inner;
          outer.left = outer;
          outer.right = outer;
          outer.top = outer-top;
          outer.bottom = outer-bottom;
        };

        mode = {
          main.binding = {
            alt-enter = "exec-and-forget open -na Ghostty";
            alt-slash = "layout tiles horizontal vertical";

            alt-cmd-h = "focus left";
            alt-cmd-j = "focus down";
            alt-cmd-k = "focus up";
            alt-cmd-l = "focus right";

            alt-cmd-shift-h = "move left";
            alt-cmd-shift-j = "move down";
            alt-cmd-shift-k = "move up";
            alt-cmd-shift-l = "move right";

            alt-cmd-shift-minus = "resize smart -50";
            alt-cmd-shift-equal = "resize smart +50";

            alt-cmd-1 = "workspace 1";
            alt-cmd-2 = "workspace 2";
            alt-cmd-3 = "workspace 3";
            alt-cmd-4 = "workspace 4";
            alt-cmd-5 = "workspace 5";
            alt-cmd-6 = "workspace 6";
            alt-cmd-7 = "workspace 7";
            alt-cmd-8 = "workspace 8";
            alt-cmd-9 = "workspace 9";
            alt-cmd-0 = "workspace 0";

            alt-cmd-shift-1 = "move-node-to-workspace 1";
            alt-cmd-shift-2 = "move-node-to-workspace 2";
            alt-cmd-shift-3 = "move-node-to-workspace 3";
            alt-cmd-shift-4 = "move-node-to-workspace 4";
            alt-cmd-shift-5 = "move-node-to-workspace 5";
            alt-cmd-shift-6 = "move-node-to-workspace 6";
            alt-cmd-shift-7 = "move-node-to-workspace 7";
            alt-cmd-shift-8 = "move-node-to-workspace 8";
            alt-cmd-shift-9 = "move-node-to-workspace 9";
            alt-cmd-shift-0 = "move-node-to-workspace 0";

            alt-tab = "workspace-back-and-forth";

            alt-shift-semicolon = "mode service";
            alt-space = "mode launch";
            alt-cmd-f = "macos-native-fullscreen";
          };
          service.binding = {
            esc = ["reload-config" "mode main"];
            r = ["flatten-workspace-tree" "mode main"]; # reset layout
            f = ["layout floating tiling" "mode main"]; # Toggle between floating and tiling layout
            backspace = ["close-all-windows-but-current" "mode main"];

            alt-shift-h = ["join-with left" "mode main"];
            alt-shift-j = ["join-with down" "mode main"];
            alt-shift-k = ["join-with up" "mode main"];
            alt-shift-l = ["join-with right" "mode main"];
          };
          launch.binding = {
            esc = ''mode main'';
            m = [''exec-and-forget ${ghostty_and} "${float_and} ${btop}"'' ''mode main''];
            x = [''exec-and-forget ${ghostty_and} "${float_and} ${launcher}"'' ''mode main''];
            f = [''exec-and-forget open ~/'' ''mode main''];
            s = [''exec-and-forget open "x-apple.systempreferences:"'' ''mode main''];
            p = [''exec-and-forget open /System/Applications/Passwords.app'' ''mode main''];
            r = [''exec-and-forget ${ghostty_and} "${float_and} zsh -ic reload-hm" --wait-after-command'' ''mode main''];
          };
        };
        on-window-detected = [
          {
            "if".window-title-regex-substring = "Application Launcher";
            run = "layout floating";
          }
          {
            "if".window-title-regex-substring = "System Monitor";
            run = "layout floating";
          }
          {
            "if".window-title-regex-substring = "OriAndTheWillOfTheWisps";
            run = "layout floating";
          }
          {
            "if".window-title-regex-substring = "Dwarf Fortress";
            run = "layout floating";
          }
        ];
      };
    };

    home.activation."aerospace" = lib.hm.dag.entryAfter [ "setupLaunchAgents" "onFilesChange" "installPackages"] ''
      ${aerospace} reload-config
    '';
  };
}
