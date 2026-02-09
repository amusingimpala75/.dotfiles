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

  override-overlays = [ self.overlays.macos-bin ];
  additive-overlays = [
    inputs.alacritty-theme.overlays.default
    inputs.bible.overlays.default
    (final: _: { bleeding = import-nixpkgs inputs.nixpkgs-bleeding final.stdenv.hostPlatform.system; })
    inputs.brew-nix.overlays.default
    self.overlays.brew-hashes
    self.overlays.default
    inputs.emacs-overlay.overlays.default
    self.overlays.emacs-packages
    (final: _: { jj-spr = inputs.jj-spr.packages.${final.stdenv.hostPlatform.system}.default; })
    self.overlays.nixvim
    (final: _: {
      nix-wallpaper = inputs.nix-wallpaper.packages.${final.stdenv.hostPlatform.system}.default;
    })
    inputs.nur.overlays.default
    (final: _: { spicetify = inputs.spicetify.legacyPackages.${final.stdenv.hostPlatform.system}; })
    (final: _: {
      stable = import-nixpkgs (
        if final.stdenv.isDarwin then inputs.nixpkgs-stable-darwin else inputs.nixpkgs-stable-nixos
      ) final.stdenv.hostPlatform.system;
    })
  ];

  overlays = additive-overlays ++ override-overlays;

  import-nixpkgs =
    np: system:
    import np {
      inherit system;
      config.allowUnfreePredicate = unfree-predicate;
      overlays = override-overlays;
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
