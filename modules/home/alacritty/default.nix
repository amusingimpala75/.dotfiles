{ lib, config, pkgs, ... }:
let
  cfg = config.my.alacritty;
  rice = config.rice;
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
          opacity = rice.opacity;
          option_as_alt = "Both";
        };
        font.size = rice.font.size;
        font.normal = {
          family = rice.font.family.fixed-pitch;
          style = "Regular";
        };

        colors = let
          red = "#${rice.base08}";
          green = "#${rice.theme.base0B}";
          yellow = "#${rice.theme.base0A}";
          cyan = "#${rice.theme.base0C}";
          blue = "#${rice.theme.base0D}";
          magenta = "#${rice.theme.base0E}";
        in {
          primary.foreground = "#${rice.theme.base06}";
          primary.background = "#${rice.theme.base00}";
          normal = {
            inherit red green yellow cyan blue magenta;
            black = "#${rice.theme.base00}";
            white = "#${rice.theme.base06}";
          };
          bright = {
            inherit red green yellow cyan blue magenta;
            black = "#${rice.theme.base03}";
            white = "#${rice.theme.base07}";
          };
        };
      };
    };
  };
}
