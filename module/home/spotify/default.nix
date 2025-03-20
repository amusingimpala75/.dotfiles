{ lib, config, pkgs, inputs, ...}:
let
  cfg = config.my.spotify;
in {
  imports = [ inputs.spicetify.homeManagerModules.default ];

  options.my.spotify = {
    enable = lib.mkEnableOption "my spotify configuration";
    adblock = lib.mkEnableOption "spotify adblock";
  };

  config = lib.mkIf cfg.enable {
    programs.spicetify = {
      enable = true;
      enabledExtensions = lib.mkIf cfg.adblock [ pkgs.spicetify.extensions.adblock ];
      theme = pkgs.spicetify.themes.text;
      colorScheme = "gruvbox"; # TODO unhardcode
    };
  };
}
