{ lib, config, pkgs, userSettings, ... }:

{
  home.sessionVariables = {
    TERM="alacritty";
  };
  programs.alacritty = {
    enable = true;
    settings = {
      shell = "${pkgs.zsh}/bin/zsh";
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
      live_config_reload = true;

      colors = let
        red = "#${userSettings.theme.base08}";
        green = "#${userSettings.theme.base0B}";
        yellow = "#${userSettings.theme.base0A}";
        cyan = "#${userSettings.theme.base0C}";
        blue = "#${userSettings.theme.base0D}";
        magenta = "#${userSettings.theme.base0E}";
      in {
        primary.foreground = "#${userSettings.theme.base06}";
        primary.background = "#${userSettings.theme.base00}";
	normal = {
	  inherit red green yellow cyan blue magenta;
	  black = "#${userSettings.theme.base00}";
	  white = "#${userSettings.theme.base06}";
	};
	bright = {
	  inherit red green yellow cyan blue magenta;
	  black = "#${userSettings.theme.base03}";
	  white = "#${userSettings.theme.base07}";
	};
      };
    };
  };
}
