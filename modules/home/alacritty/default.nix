{ lib, config, pkgs, userSettings, ... }:
let
  cfg = config.my.alacritty;
in {
  options.my.alacritty = {
    enable = lib.mkEnableOption "alacritty config";
  };

  config = lib.mkIf cfg.enable {
    home.sessionVariables = {
      TERM="alacritty";
    };
    programs.alacritty = {
      enable = true;
      settings = {
        general = {
          live_config_reload = true;
        };
        terminal = {
          shell = "${pkgs.zsh}/bin/zsh"; # :TODO: genericize
        };
        window = {
          # decorations = "Buttonless";
          padding = {
            x = 4;
            y = 4;
          };
          opacity = userSettings.opacity;
          option_as_alt = "Both";
        };
        font.size = userSettings.font.size;
        font.normal = {
          family = userSettings.font.family.fixed-pitch;
          style = "Regular";
        };

        colors = let
          red = "#${config.theme.base08}";
          green = "#${config.theme.base0B}";
          yellow = "#${config.theme.base0A}";
          cyan = "#${config.theme.base0C}";
          blue = "#${config.theme.base0D}";
          magenta = "#${config.theme.base0E}";
        in {
          primary.foreground = "#${config.theme.base06}";
          primary.background = "#${config.theme.base00}";
          normal = {
            inherit red green yellow cyan blue magenta;
            black = "#${config.theme.base00}";
            white = "#${config.theme.base06}";
          };
          bright = {
            inherit red green yellow cyan blue magenta;
            black = "#${config.theme.base03}";
            white = "#${config.theme.base07}";
          };
        };
      };
    };
  };
}
