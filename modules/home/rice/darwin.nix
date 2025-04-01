{ lib, config, pkgs, ... }:
let
  appearancePackage = pkgs.writeShellScriptBin "set-appearance.sh" ''
    /usr/bin/osascript -e "tell app \"System Events\" to tell appearance preferences to set dark mode to $1"
  '';
  stdenv = pkgs.stdenv;
in {
  config = lib.mkIf stdenv.isDarwin {
    home.activation.set-system-ui = (lib.hm.dag.entryAfter ["writeBoundary"] ''
      ${appearancePackage}/bin/set-appearance.sh ${ if config.rice.theme.darkMode then "true" else "false" }
    '');

    home.activation.set-wallpaper = (lib.hm.dag.entryAfter ["writeBoundary"] ''
      ${pkgs.desktoppr}/bin/desktoppr ${config.rice.wallpaper}
    '');
  };
}
