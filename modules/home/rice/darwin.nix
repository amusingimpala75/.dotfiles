{
  lib,
  config,
  pkgs,
  ...
}:
{
  config = lib.mkIf pkgs.stdenv.isDarwin {
    home.activation.set-system-ui = (
      lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        ${lib.getExe pkgs.set-appearance} ${if config.rice.theme.darkMode then "true" else "false"}
      ''
    );

    home.activation.set-wallpaper = (
      lib.hm.dag.entryBetween [ "restart-dock" ] [ "writeBoundary" ] ''
        ${lib.getExe pkgs.desktoppr} ${config.rice.wallpaper}
      ''
    );
  };
}
