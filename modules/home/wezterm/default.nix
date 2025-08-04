{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.my.wezterm;
in
{
  options.my.wezterm.enable = lib.mkEnableOption "my wezterm config";

  config = lib.mkIf cfg.enable {
    programs.wezterm = {
      enable = true;
      extraConfig = builtins.readFile (
        pkgs.fennelToLua {
          name = "wezterm-config";
          src = pkgs.writeText "config.fnl" ''
            (local config ${builtins.readFile config.rice.fennel-defaults})
            ${builtins.readFile ./config.fnl}
          '';
        }
      );
      colorSchemes = {
        my-base16 = with config.rice.theme; {
          ansi = [
            base08
            base09
            base0A
            base0B
            base0C
            base0D
            base0E
            base0F
          ];
          brights = [
            base08
            base09
            base0A
            base0B
            base0C
            base0D
            base0E
            base0F
          ];
          background = base02;
          foreground = base05;
          cursor_bg = base04;
          cursor_border = base04;
          cursor_fg = base03;

          metadata = {
            name = "my-base16";
          };
        };
      };
    };
  };
}
