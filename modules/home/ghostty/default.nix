{ lib, config, pkgs, ...}:
let
  cfg = config.my.ghostty;
  rice = config.rice;
in {
  # TODO figure out why .zshenv -> ~/.config/zsh/.zshenv -> ~/.config/zsh/.zshrc is not being sourced
  #      (ZDOTDIR is overridden by ghostty integration as /Applications/Ghostty.app/<etc>)
  imports = [ ./darwin.nix ];

  options.my.ghostty = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      example = true;
      description = "enable ghostty configuration";
    };

    package = lib.mkOption {
      type = lib.types.nullOr lib.types.package;
      default = pkgs.ghostty;
      example = null;
      description = "package to use for ghostty";
    };
  };

  config = lib.mkIf cfg.enable {
    programs.ghostty = {
      package = cfg.package;
      enable = true;
      enableZshIntegration = true; # :TODO: genericize
      settings = with rice; {
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
        base16 = with config.rice.theme; {
          background = "${base00}";
          foreground = "${base06}";
          palette = [
            "0=#${base00}"
            "1=#${base08}"
            "2=#${base0B}"
            "3=#${base0A}"
            "4=#${base0D}"
            "5=#${base0E}"
            "6=#${base0C}"
            "7=#${base05}"
            "8=#${base08}"
            "9=#${base03}"
            "10=#${base08}"
            "11=#${base0B}"
            "12=#${base0A}"
            "13=#${base0D}"
            "14=#${base0E}"
            "15=#${base0C}"
            "16=#${base07}"
            "17=#${base09}"
            "18=#${base0F}"
            "19=#${base01}"
            "20=#${base02}"
            "21=#${base04}"
            "22=#${base06}"
          ];
        };
      };
    };
  };
}
