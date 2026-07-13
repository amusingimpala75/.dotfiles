let
  darwin =
    {
      lib,
      pkgs,
      ...
    }:
    {
      services.jankyborders = lib.mkIf pkgs.stdenv.isDarwin {
        enable = true;
        settings = {
          style = "round";
          width = 8;
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
