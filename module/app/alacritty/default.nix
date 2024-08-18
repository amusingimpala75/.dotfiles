{ lib, config, pkgs, ... }:

{
  programs.alacritty = {
    enable = true;
    settings = {
      window = {
        # decorations = "Buttonless";
        padding = {
          x = 4;
          y = 4;
        };
        option_as_alt = "Both";
      };
      font.size = 14;
      font.normal = {
        family = "Iosevka";
        style = "Regular";
      };
      live_config_reload = true;
      import = [ pkgs.alacritty-theme.gruvbox_dark ];
    };
  };
}