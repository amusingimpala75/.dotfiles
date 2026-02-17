{
  inputs,
  lib,
  self,
  ...
}:
let
  unfree-predicate =
    pkg:
    builtins.elem (lib.getName pkg) [
      "copilot-language-server"
      "dwarf-fortress"
      "gaoptout" # Google Analytics Opt-Out Firefox Addon
      "modrinth-app" # it for some reason has both gpl3+ and unfree redistributable?
      "modrinth-app-unwrapped"
      "orbstack"
      "slack"
      "spacefox-theme"
      "spotify"
      "youtube-recommended-videos"
      "zoom"
    ];

  bleeding = final: _: {
    bleeding = import-nixpkgs inputs.nixpkgs-bleeding final.stdenv.hostPlatform.system;
  };
  stable = final: _: {
    stable = import-nixpkgs (
      if final.stdenv.isDarwin then inputs.nixpkgs-stable-darwin else inputs.nixpkgs-stable-nixos
    ) final.stdenv.hostPlatform.system;
  };

  overlays = [
    bleeding
    stable

    inputs.emacs-overlay.overlays.default
    self.overlays.emacs-packages

    self.overlays.lib
    self.overlays.common
    self.overlays.nixvim
    inputs.nur.overlays.default
  ];

  darwin-overlays = [
    self.overlays.darwin
  ];

  linux-overlays = [
    self.overlays.linux
  ];

  config = {
    allowUnfreePredicate = unfree-predicate;
  };

  import-nixpkgs =
    np: system:
    import np {
      inherit config system;
    };
in
{
  flake.modules.generic.nixpkgs = {
    config.nixpkgs = {
      inherit config;
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
        inherit config system;
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
