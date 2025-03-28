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
    home.shellAliases = {
      nds = "nix develop -c $SHELL";
      reload-hm = "home-manager switch -b backup --flake ${dotfilesDir}#${config.home.username}";
      reload-nd = if pkgs.stdenv.isDarwin then "darwin-rebuild switch --flake ${dotfilesDir}" else "echo 'Did you mean reload-no?'";
      reload-no = if pkgs.stdenv.isLinux  then "sudo nixos-rebuild switch --flake ${dotfilesDir}" else "echo 'Did you mean reload-nd?'";
      reload-config = if pkgs.stdenv.isLinux then "reload-no && reload-hm" else "reload-nd && reload-hm";
    };
  };
}
