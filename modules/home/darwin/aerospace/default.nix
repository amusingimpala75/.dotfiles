{
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.my.aerospace;
  rice = config.rice;
  stdenv = pkgs.stdenv;

  aerospace = "${pkgs.aerospace}/bin/aerospace";
  bash = "${pkgs.bash}/bin/bash";
  btop = "${pkgs.btop}/bin/btop";
  float_and = "${pkgs.float_and}/bin/float_and";
  ghostty_and = "${pkgs.ghostty_and}/bin/ghostty_and";
  launcher = "${pkgs.my.launcher}/bin/launcher";
  sketchybar = "${pkgs.sketchybar}/bin/sketchybar";
  new-ghostty = "${pkgs.my.new-ghostty-window}/bin/new-ghostty-window";
in
{
  options.my.aerospace = {
    enable = lib.mkEnableOption "my aerospace config";
  };

  config = lib.mkIf (cfg.enable && stdenv.isDarwin) {
    programs.aerospace = {
      enable = true;

      launchd.enable = true;
      settings = {
        after-startup-command = [ "exec-and-forget ${sketchybar}" ];
        exec-on-workspace-change = [
          "${bash}"
          "-c"
          "${sketchybar} --trigger aerospace_workspace_change FOCUSED_WORKSPACE=$AEROSPACE_FOCUSED_WORKSPACE & /Users/lukemurray/projects/desktop_shell/bring-shell.sh $AEROSPACE_FOCUSED_WORKSPACE"
        ];
        enable-normalization-flatten-containers = true;
        enable-normalization-opposite-orientation-for-nested-containers = true;

        accordion-padding = 30;
        default-root-container-layout = "tiles";
        default-root-container-orientation = "auto";

        key-mapping.preset = "qwerty";

        on-focused-monitor-changed = [ "move-mouse monitor-lazy-center" ];

        gaps =
          let
            inner = rice.gaps.inner * 2;
            outer = rice.gaps.outer;
            outer-top = rice.gaps.outer + rice.bar.height + rice.gaps.outer;
            outer-bottom = rice.gaps.outer - 1;
          in
          {
            inner.horizontal = inner;
            inner.vertical = inner;
            outer.left = outer * 3;
            outer.right = outer;
            outer.top = outer-top;
            outer.bottom = outer-bottom;
          };

        mode = {
          main.binding = {
            ctrl-alt-cmd-enter = "exec-and-forget ${new-ghostty}";
            ctrl-alt-cmd-slash = "layout tiles horizontal vertical";

            ctrl-alt-cmd-h = "focus left";
            ctrl-alt-cmd-j = "focus down";
            ctrl-alt-cmd-k = "focus up";
            ctrl-alt-cmd-l = "focus right";

            ctrl-alt-cmd-shift-h = "move left";
            ctrl-alt-cmd-shift-j = "move down";
            ctrl-alt-cmd-shift-k = "move up";
            ctrl-alt-cmd-shift-l = "move right";

            ctrl-alt-cmd-shift-minus = "resize smart -50";
            ctrl-alt-cmd-shift-equal = "resize smart +50";

            ctrl-alt-cmd-1 = "workspace 1";
            ctrl-alt-cmd-2 = "workspace 2";
            ctrl-alt-cmd-3 = "workspace 3";
            ctrl-alt-cmd-4 = "workspace 4";
            ctrl-alt-cmd-5 = "workspace 5";
            ctrl-alt-cmd-6 = "workspace 6";
            ctrl-alt-cmd-7 = "workspace 7";
            ctrl-alt-cmd-8 = "workspace 8";
            ctrl-alt-cmd-9 = "workspace 9";

            ctrl-alt-cmd-shift-1 = "move-node-to-workspace 1";
            ctrl-alt-cmd-shift-2 = "move-node-to-workspace 2";
            ctrl-alt-cmd-shift-3 = "move-node-to-workspace 3";
            ctrl-alt-cmd-shift-4 = "move-node-to-workspace 4";
            ctrl-alt-cmd-shift-5 = "move-node-to-workspace 5";
            ctrl-alt-cmd-shift-6 = "move-node-to-workspace 6";
            ctrl-alt-cmd-shift-7 = "move-node-to-workspace 7";
            ctrl-alt-cmd-shift-8 = "move-node-to-workspace 8";
            ctrl-alt-cmd-shift-9 = "move-node-to-workspace 9";
            ctrl-alt-cmd-shift-0 = "move-node-to-workspace 0";

            ctrl-alt-cmd-0 = "workspace-back-and-forth";

            ctrl-alt-cmd-shift-semicolon = "mode service";
            ctrl-alt-cmd-space = "mode launch";
            ctrl-alt-cmd-f = "macos-native-fullscreen";
          };
          service.binding = {
            esc = [
              "reload-config"
              "mode main"
            ];
            r = [
              "flatten-workspace-tree"
              "mode main"
            ]; # reset layout
            f = [
              "layout floating tiling"
              "mode main"
            ]; # Toggle between floating and tiling layout
            backspace = [
              "close-all-windows-but-current"
              "mode main"
            ];

            alt-shift-h = [
              "join-with left"
              "mode main"
            ];
            alt-shift-j = [
              "join-with down"
              "mode main"
            ];
            alt-shift-k = [
              "join-with up"
              "mode main"
            ];
            alt-shift-l = [
              "join-with right"
              "mode main"
            ];
          };
          launch.binding = {
            esc = ''mode main'';
            # :TODO: there has to be a better way to express this
            e = [
              ''exec-and-forget ${config.my.emacs.package}/bin/${config.my.emacs.gui-command}''
              ''mode main''
            ];
            m = [
              ''exec-and-forget ${ghostty_and} "${float_and} ${btop}"''
              ''mode main''
            ];
            x = [
              ''exec-and-forget ${ghostty_and} "${float_and} ${launcher}"''
              ''mode main''
            ];
            f = [
              ''exec-and-forget open ~/''
              ''mode main''
            ];
            s = [
              ''exec-and-forget open "x-apple.systempreferences:"''
              ''mode main''
            ];
            p = [
              ''exec-and-forget open /System/Applications/Passwords.app''
              ''mode main''
            ];
            r = [
              ''exec-and-forget ${ghostty_and} "${float_and} zsh -ic reload-hm" --wait-after-command''
              ''mode main''
            ];
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
          {
            "if".window-title-regex-substring = "Brogue";
            run = "layout floating";
          }
          {
            "if".window-title-regex-substring = "My Shell";
            run = "layout floating";
          }
        ];
      };
    };

    home.activation."aerospace" =
      lib.hm.dag.entryAfter [ "setupLaunchAgents" "onFilesChange" "installPackages" ]
        ''
          ${aerospace} reload-config
        '';
  };
}
