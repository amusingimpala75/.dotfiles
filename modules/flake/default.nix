{
  inputs,
  lib,
  ...
}:
{
  imports = [
    inputs.flake-parts.flakeModules.modules
    inputs.nix-darwin.flakeModules.default
    inputs.home-manager.flakeModules.home-manager
  ];
  systems = lib.systems.flakeExposed;
  perSystem =
    {
      pkgs,
      self',
      ...
    }:
    {
      packages = {
        default = self'.packages.install;

        emacs = pkgs.my.emacs;
        install = pkgs.my.install;
      };

      formatter = pkgs.nixfmt-tree;
    };
}
