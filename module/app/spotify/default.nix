{ lib, config, pkgs, userSettings, spicetify, ...}:
let
  spkgs = spicetify.legacyPackages.${pkgs.stdenv.system};
in {
  imports = [ spicetify.homeManagerModules.default ];
  programs.spicetify = {
    enable = true;
    enabledExtensions = (with spkgs.extensions; [
      adblockify
    ]);
    theme = spkgs.themes.text;
    colorScheme = "gruvbox"; # TODO unhardcode
  };
}
