{
  flake.modules.homeManager.wallust = {
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
        };
        hooks = {
          ghostty = ''osascript -e 'tell application "Ghostty" to perform action "reload_config" on focused terminal of selected tab of front window' > /dev/null'';
        };
      };
    };
  };
}
