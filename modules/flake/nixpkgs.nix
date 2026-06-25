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
    bleeding

    inputs.emacs-overlay.overlays.default
    self.overlays.emacs-packages

    self.overlays.lib
    # Here we leave the packages that are broken in unstable but working in bleeding
    (_: prev: {
      inherit (prev.bleeding) ntfy-sh pi-coding-agent zuban;
      darwin = prev.darwin.overrideScope (
        _: dprev: {
          inherit (prev.bleeding.darwin) PowerManagement;
        }
      );
    })

    self.overlays.common
  ];

  darwin-overlays = [
    self.overlays.darwin
  ];

  linux-overlays = [
    self.overlays.linux
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
        overlays = [
          self.overlays.preface
        ]
        ++ overlays
        ++ darwin-overlays
        ++ linux-overlays
        ++ [ self.overlays.flatten ];
      };
    };

  perSystem =
    { system, ... }:
    {
      _module.args.pkgs = import inputs.nixpkgs {
        inherit system;
        overlays = [
          self.overlays.preface
        ]
        ++ overlays
        ++ (lib.optionals (lib.hasSuffix "linux" system) linux-overlays)
        ++ (lib.optionals (lib.hasSuffix "darwin" system) darwin-overlays)
        ++ [ self.overlays.flatten ];
      };
    };
}
