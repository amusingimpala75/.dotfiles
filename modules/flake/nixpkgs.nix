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

  overlays = [
    (final: _: { bleeding = import-nixpkgs inputs.nixpkgs-bleeding final.stdenv.hostPlatform.system; })
    self.overlays.default
    self.overlays.linux
    self.overlays.darwin
    inputs.emacs-overlay.overlays.default
    self.overlays.emacs-packages
    self.overlays.nixvim
    inputs.nur.overlays.default
    (final: _: {
      stable = import-nixpkgs (
        if final.stdenv.isDarwin then inputs.nixpkgs-stable-darwin else inputs.nixpkgs-stable-nixos
      ) final.stdenv.hostPlatform.system;
    })
  ];

  import-nixpkgs =
    np: system:
    import np {
      inherit system;
      config.allowUnfreePredicate = unfree-predicate;
    };

  config = {
    nixpkgs = {
      config.allowUnfreePredicate = unfree-predicate;
      inherit overlays;
    };
  };
in
{
  flake.modules.generic.nixpkgs = {
    inherit config;
  };
  perSystem =
    { system, ... }:
    {
      _module.args.pkgs = import inputs.nixpkgs {
        inherit system;
        inherit (config.nixpkgs) config overlays;
      };
    };
}
