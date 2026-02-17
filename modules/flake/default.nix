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
      ...
    }:
    {
      packages = {
        default = pkgs.local.install;
      }
      // (lib.filterAttrs (_: v: lib.isDerivation v) pkgs.local);

      formatter = pkgs.nixfmt-tree;
    };
}
