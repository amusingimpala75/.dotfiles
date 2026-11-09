# CI-only package outputs: keep unfree permission out of the normal flake.
{ flake }:
let
  inputs = flake.inputs // {
    self = flake;
  };
  lib = inputs.nixpkgs.lib;
  nixpkgsModule = import ../../modules/nixpkgs.nix {
    inherit inputs lib;
    self = flake;
  };
in
(inputs.flake-parts.lib.mkFlake { inherit inputs; } {
  imports = lib.fileset.toList (
    lib.fileset.fileFilter (file: file.hasExt "nix" && !(lib.hasPrefix "_" file.name)) ../../modules
  );
  perSystem =
    { system, ... }:
    {
      _module.args.pkgs = lib.mkForce (
        import inputs.nixpkgs {
          inherit system;
          inherit ((nixpkgsModule.perSystem { inherit system; })._module.args.pkgs) overlays;
          config.allowUnfree = true;
        }
      );
    };
}).packages
