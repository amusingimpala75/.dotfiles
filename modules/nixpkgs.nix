{
  inputs,
  lib,
  self,
  ...
}:
let
  bleeding = final: _: {
    bleeding = import inputs.nixpkgs-bleeding {
      inherit (final.stdenv.hostPlatform) system;
    };
  };

  overlays = [
    self.overlays.preface

    bleeding

    inputs.emacs-overlay.overlays.default
    self.overlays.emacs-packages

    (final: prev: {
      emacsPackagesFor =
        emacs:
        ((prev.emacsPackagesFor emacs).overrideScope (
          efinal: _: {
            inherit (efinal.melpaPackages) telega;
          }
        ));
    })

    self.overlays.lib

    self.overlays.by-name

    self.overlays.flatten
  ];
in
{
  flake.modules.generic.nixpkgs =
    { config, ... }:
    {
      options.nixpkgs.allowUnfreeList = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [ ];
      };
      config.nixpkgs = {
        config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) config.nixpkgs.allowUnfreeList;
        inherit overlays;
      };
    };

  perSystem =
    { system, ... }:
    {
      _module.args.pkgs = import inputs.nixpkgs {
        inherit overlays system;
      };
    };
}
