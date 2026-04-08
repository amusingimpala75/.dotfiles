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
    nix-search = (lib.mkEnableOption "nix search CLI utility") // {
      default = true;
    };
    dotfilesDir = lib.mkOption {
      type = lib.types.str;
      default = "~/.dotfiles";
      example = "~/git/dotfiles";
      description = "path to dotfiles";
    };
  };

  config = lib.mkIf cfg.enable {
    programs = {
      nh = lib.mkIf cfg.nh {
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

      nix-index.enable = false;
      nix-index-database.comma.enable = true;
    };

    home = {
      shellAliases = {
        nds = "nix develop -c $SHELL";
      };
      packages = with pkgs; [
        nix-tree
        (writeShellApplication {
          name = "ns";
          runtimeInputs = [
            fzf
            nix-search-tv
          ];
          text = builtins.readFile "${nix-search-tv.src}/nixpkgs.sh";
        })
      ];
    };
  };
}
