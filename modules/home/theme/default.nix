{ lib, pkgs, ...}:
{
  imports = [ ./darwin.nix ];

  options.theme = lib.mkOption {
    type = lib.types.attrs;
    default = pkgs.my.schemes.gruvbox-dark-hard;
    example = pkgs.my.schemes.solarized-dark;
    description = "theme to use for scheming";
  };
}
