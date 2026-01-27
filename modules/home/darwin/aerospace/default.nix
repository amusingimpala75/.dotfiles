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
  btop = "${pkgs.btop}/bin/btop";
  float_and = "${pkgs.float_and}/bin/float_and";
  ghostty_and = "${pkgs.ghostty_and}/bin/ghostty_and";
  new-ghostty = "${pkgs.my.new-ghostty-window}/bin/new-ghostty-window";

  back-main = builtins.mapAttrs (
    k: v: [
      v
      "mode main"
    ]
  );

  exec-back-main = builtins.mapAttrs (
    k: v: [
      "exec-and-forget ${v} "
      "mode main"
    ]
  );

  gen-keybinds =
    attrs: keybind: command:
    lib.mapAttrs' (k: v: {
      name = "${keybind}-${k}";
      value = "${command} ${v}";
    }) attrs;

  gen-workspaces = gen-keybinds (
    lib.genAttrs (builtins.map builtins.toString (lib.range 1 9)) (s: s)
  );

  gen-vim-directions = gen-keybinds {
    h = "left";
    j = "down";
    k = "up";
    l = "right";
  };
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

            ctrl-alt-cmd-shift-minus = "resize smart -50";
            ctrl-alt-cmd-shift-equal = "resize smart +50";

            ctrl-alt-cmd-0 = "workspace-back-and-forth";

            ctrl-alt-cmd-shift-semicolon = "mode service";
            ctrl-alt-cmd-space = "mode launch";
            ctrl-alt-cmd-f = "macos-native-fullscreen";
          }
          // (gen-workspaces "ctrl-alt-cmd" "workspace")
          // (gen-workspaces "ctrl-alt-cmd-shift" "move-node-to-workspace")
          // (gen-vim-directions "ctrl-alt-cmd" "focus")
          // (gen-vim-directions "ctrl-alt-cmd-shift" "move");
          service.binding =
            { }
            // back-main (
              {
                esc = "reload-config";
                r = "flatten-workspace-tree";
                f = "layout floating tiling";
                backspace = "close-all-windows-but-current";
              }
              // (gen-vim-directions "alt-shift" "join-with")
            );
          launch.binding = {
            esc = "mode main";
          }
          // exec-back-main {
            e = "${config.my.emacs.package}/bin/${config.my.emacs.gui-command} ";
            m = ''${ghostty_and} "${float_and} ${btop}"'';
            f = "open ~/";
            s = ''open "x-apple.systempreferences:"'';
            p = "open /System/Applications/Passwords.app/";
            r = ''${ghostty_and} "${float_and} zsh -ic reload-hm" --wait-after-command '';
          };
        };
        on-window-detected =
          builtins.map
            (name: {
              "if".window-title-regex-substring = name;
              run = "layout floating";
            })
            [
              "System Monitor"
              "OriAndTheWillOfTheWisps"
              "Dwarf Fortress"
              "Brogue"
              "My Shell"
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
