{
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.my.jankyborders;
  stdenv = pkgs.stdenv;
  inherit (config.rice.border)
    active
    inactive
    width
    radius
    ;
in
{
  options.my.jankyborders = {
    enable = lib.mkEnableOption "my janky borders configuration";
  };

  config = lib.mkIf (cfg.enable && stdenv.isDarwin) {
    launchd.agents."jankyborders" = {
      enable = true;
      config = rec {
        Program = lib.getExe pkgs.jankyborders;
        ProgramArguments = [
          Program
          "style=${if radius == 0 then "square" else "round"}"
          "active_color=0xff${toString active}"
          "inactive_color=0xff${toString inactive}"
          "width=${toString width}"
          "blacklist=desktop_shell"
        ];
        KeepAlive = true;
      };
    };
  };
}
