{ lib, pkgs, userSettings, ... }:
let
  appearancePackage = pkgs.writeShellScriptBin "set-appearance.sh" ''
    /usr/bin/osascript -e "tell app \"System Events\" to tell appearance preferences to set dark mode to $1"
  '';
in
{
  home.activation = {
    set-system-ui = lib.mkIf pkgs.stdenv.hostPlatform.isDarwin (lib.hm.dag.entryAfter ["writeBoundary"] ''
      ${appearancePackage}/bin/set-appearance.sh ${ if userSettings.theme.darkMode then "true" else "false" }
    '');
  };
}