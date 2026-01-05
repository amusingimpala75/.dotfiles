{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.my.nix;
in
{
  imports = [ inputs.nix-index-database.homeModules.nix-index ];

  options.my.nix = {
    enable = lib.mkEnableOption "nix customization";
    nh = lib.mkOption {
      type = lib.types.bool;
      default = cfg.enable;
      example = false;
      description = "enable NH";
    };
    dotfilesDir = lib.mkOption {
      type = lib.types.str;
      default = "~/.dotfiles";
      description = "path to dotfiles";
    };
  };

  config = lib.mkIf cfg.enable {
    programs.nh = lib.mkIf cfg.nh {
      enable = true;
      flake =
        if lib.strings.hasPrefix "~" cfg.dotfilesDir then
          (lib.concatStrings [
            config.home.homeDirectory
            (builtins.substring 1 (-1) cfg.dotfilesDir)
          ])
        else
          cfg.dotfilesDir;
    };

    programs.nix-index-database.comma.enable = true;

    home = {
      shellAliases = {
        nds = "nix develop -c $SHELL";
      };
      packages = [
        pkgs.nix-tree
      ];
    };
  };
}
