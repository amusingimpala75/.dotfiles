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
          active_color = "0xff${toString config.rice.border.active}";
          inactive_color = "0xff${toString config.rice.border.inactive}";
          inherit (config.rice.border) width;
          blacklist = "desktop_shell";
        };
      };
    };
in
{
  flake.modules.homeManager.window-borders = {
    imports = [ darwin ];
  };
}
