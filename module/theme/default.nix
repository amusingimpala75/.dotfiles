{ lib, config, pkgs, ... }:
let
  appearancePackage = pkgs.writeShellScriptBin "set-appearance.sh" ''
    /usr/bin/osascript -e "tell app \"System Events\" to tell appearance preferences to set dark mode to $1"
  '';
in {
  options.theme = lib.mkOption {
    default = import ./generated/gruvbox-dark-hard;
    description = "Attr set containing theme at basexx (e.g. base00)";
  };

  config = {
    home.activation = {
      set-system-ui = lib.mkIf pkgs.stdenv.hostPlatform.isDarwin (lib.hm.dag.entryAfter ["writeBoundary"] ''
        ${appearancePackage}/bin/set-appearance.sh ${ if config.theme.darkMode then "true" else "false" }
      '');
    };
  };
}
