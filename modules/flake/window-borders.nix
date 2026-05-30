let
  darwin =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    {
      services.jankyborders = lib.mkIf pkgs.stdenv.isDarwin {
        enable = true;
        settings = {
          style = if config.rice.border.radius == 0 then "square" else "round";
          inherit (config.rice.border) width;
        };
      };

      programs.wallust.settings = {
        templates.jankyborders = lib.mkIf pkgs.stdenv.isDarwin {
          template = ./wallust/jankyborders.wallust;
          target = "~/.config/jankyborders/wallust.json";
        };
        hooks.jankyborders = lib.mkIf pkgs.stdenv.isDarwin ''
          borders active_color="$(jaq -r '.active' < ~/.config/jankyborders/wallust.json)" inactive_color="$(jaq -r '.inactive' < ~/.config/jankyborders/wallust.json)"
        '';

      };
    };
in
{
  flake.modules.homeManager.window-borders = {
    imports = [ darwin ];
  };
}
