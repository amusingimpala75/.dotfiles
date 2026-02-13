{
  lib,
  config,
  pkgs,
  ...
}:
let
  inherit (config.rice.border)
    active
    inactive
    width
    radius
    ;
in
{
  options.my.jankyborders.enable = lib.mkEnableOption "my janky borders configuration";

  config.services.jankyborders = lib.mkIf (config.my.jankyborders.enable && pkgs.stdenv.isDarwin) {
    enable = true;
    settings = {
      style = if radius == 0 then "square" else "round";
      active_color = "0xff${toString active}";
      inactive_color = "0xff${toString inactive}";
      inherit width;
      blacklist = "desktop_shell";
    };
  };
}
