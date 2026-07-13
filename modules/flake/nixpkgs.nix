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

    (final: _: { inherit (final.bleeding) nh; })

    self.overlays.lib

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
