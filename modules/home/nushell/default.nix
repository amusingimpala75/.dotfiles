{ config, lib, pkgs, ... }:
let
  cfg = config.my.nushell;
in {
  options.my.nushell = {
    enable = lib.mkEnableOption "enable nushell";
  };

  config = lib.mkIf cfg.enable {
    programs.direnv.enableNushellIntegration = lib.mkIf config.my.direnv.enable true;

    programs.nushell = {
      enable = true;
      settings = {
        show_banner = false;
      };
      configFile.source = ./config.nu;
      shellAliases = {
        reload-config = lib.mkForce (if pkgs.stdenv.isLinux then "reload-no and reload-hm" else "reload-nd and reload-hm");
        nds = lib.mkForce "nix develop -c nu";
      };
      environmentVariables = {} // config.home.sessionVariables;
    };
  };
}
