{
  lib,
  config,
  pkgs,
  ...
}:
{
  config = lib.mkIf pkgs.stdenv.isDarwin {
    home.activation.set-system-ui = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      ${lib.getExe pkgs.set-appearance} ${if config.rice.theme.darkMode then "true" else "false"}
    '';
  };
}
