{ lib, config, pkgs, userSettings, ...}:
let
  package = if pkgs.stdenv.isDarwin then pkgs.ghostty-bin else pkgs.ghostty;
in {
  # TODO figure out why .zshenv -> ~/.config/zsh/.zshenv -> ~/.config/zsh/.zshrc is not being sourced
  #      (ZDOTDIR is overridden by ghostty integration as /Applications/Ghostty.app/<etc>)

  home.file.".hushlogin".text = lib.mkIf pkgs.stdenv.isDarwin "";

  programs.ghostty = {
    package = null; # TODO
    enable = true;
    enableZshIntegration = true;
    settings = with userSettings; {
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

      # TODO genericize
      command = "${pkgs.zsh}/bin/zsh";

      auto-update = "off";

      theme = "base16";
    };
    themes = {
      base16 = with userSettings; {
        background = "${theme.base00}";
        foreground = "${theme.base06}";
        palette = [
          "0=#${theme.base00}"
          "1=#${theme.base08}"
          "2=#${theme.base0B}"
          "3=#${theme.base0A}"
          "4=#${theme.base0D}"
          "5=#${theme.base0E}"
          "6=#${theme.base0C}"
          "7=#${theme.base05}"
          "8=#${theme.base08}"
          "9=#${theme.base03}"
          "10=#${theme.base08}"
          "11=#${theme.base0B}"
          "12=#${theme.base0A}"
          "13=#${theme.base0D}"
          "14=#${theme.base0E}"
          "15=#${theme.base0C}"
          "16=#${theme.base07}"
          "17=#${theme.base09}"
          "18=#${theme.base0F}"
          "19=#${theme.base01}"
          "20=#${theme.base02}"
          "21=#${theme.base04}"
          "22=#${theme.base06}"
        ];
      };
    };
  };
}
