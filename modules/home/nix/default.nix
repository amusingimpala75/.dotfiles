{ lib, config, pkgs, dotfilesDir, ... }:
let
  cfg = config.my.nix;
in {
  options.my.nix = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      example = true;
      description = "enable nix customization";
    };
  };

  config = lib.mkIf cfg.enable {
    home = {
      packages = [ pkgs.nh ];

      shellAliases = {
        nds = "nix develop -c $SHELL";
        reload-hm = "nh home switch -b backup ${dotfilesDir}";
        reload-nd = if pkgs.stdenv.isDarwin then "nh darwin switch ${dotfilesDir}" else "echo 'Did you mean reload-no?'";
        reload-no = if pkgs.stdenv.isLinux  then "nh os switch ${dotfilesDir}" else "echo 'Did you mean reload-nd?'";
        reload-config = if pkgs.stdenv.isLinux then "reload-no && reload-hm" else "reload-nd && reload-hm";
      };
    };
  };
}
