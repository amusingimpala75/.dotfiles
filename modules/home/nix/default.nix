{ lib, config, dotfilesDir, ... }:
let
  cfg = config.my.nix;
  actual-dir =
    if lib.strings.hasPrefix "~" dotfilesDir
    then lib.concatStrings [config.home.homeDirectory (builtins.substring 1 (-1) dotfilesDir)]
    else dotfilesDir;
in {
  options.my.nix = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      example = true;
      description = "enable nix customization";
    };
    nh = lib.mkOption {
      type = lib.types.bool;
      default = cfg.enable;
      example = false;
      description = "enable NH";
    };
  };

  config = lib.mkIf cfg.enable {
    programs.nh = lib.mkIf cfg.nh {
      enable = true;
      flake = actual-dir;
    };

    home = {
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
