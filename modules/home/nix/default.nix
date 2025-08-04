{
  lib,
  config,
  dotfilesDir,
  inputs,
  ...
}:
let
  cfg = config.my.nix;
  actual-dir =
    if lib.strings.hasPrefix "~" dotfilesDir then
      lib.concatStrings [
        config.home.homeDirectory
        (builtins.substring 1 (-1) dotfilesDir)
      ]
    else
      dotfilesDir;
in
{
  imports = [ inputs.nix-index-database.homeModules.nix-index ];

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

    programs.nix-index-database.comma.enable = true;

    home = {
      shellAliases = {
        nds = "nix develop -c $SHELL";
      };
    };
  };
}
