{
  flake.modules.homeManager.wallust =
    {
      lib,
      pkgs,
      ...
    }:
    {
      programs.wallust = {
        enable = true;
        settings = {
          palette = "softdark16";
          check_contrast = true;
          templates = {
            ghostty = {
              template = ./ghostty.wallust;
              target = "~/.config/ghostty/themes/wallust";
            };
            # Really can be replaced with a templated_hook,
            # waiting for that to be properly released in 4.0
            palette = {
              template = ./palette.wallust;
              target = "~/.local/state/wallust/palette.txt";
            };
          };
          hooks = {
            ghostty = ''osascript -e 'tell application "Ghostty" to perform action "reload_config" on focused terminal of selected tab of front window' > /dev/null'';
            darwin-system-appearance = lib.mkIf pkgs.stdenv.isDarwin ''
              if grep "dark" < "$HOME/.local/state/wallust/palette.txt" > /dev/null
              then
                ${lib.getExe pkgs.set-appearance} "true"
              else
                ${lib.getExe pkgs.set-appearance} "false"
              fi
            '';
          };
        };
      };
      programs.ghostty.settings.theme = "wallust";
    };
}
