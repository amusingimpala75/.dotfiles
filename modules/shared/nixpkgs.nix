{
  inputs,
  lib,
  root,
  self,
  ...
}:
let
  unfree-predicate =
    pkg:
    builtins.elem (lib.getName pkg) [
      "dwarf-fortress"
      "gaoptout" # Google Analytics Opt-Out Firefox Addon
      "modrinth-app" # it for some reason has both gpl3+ and unfree redistributable?
      "modrinth-app-unwrapped"
      "slack"
      "spacefox-theme"
      "spotify"
      "untrap-for-youtube"
      "zoom"
    ];
  nixpkgs-stable-overlay = (
    final: prev:
    if prev.stdenv.isDarwin then
      {
        stable = import inputs.nixpkgs-stable-darwin {
          system = prev.system;
          config.allowUnfreePredicate = unfree-predicate;
        };
      }
    else
      {
        stable = import inputs.nixpkgs-stable-nixos {
          system = prev.system;
          config.allowUnfreePredicate = unfree-predicate;
        };
      }
  );
in
{
  config.nixpkgs = {
    config.allowUnfreePredicate = unfree-predicate;
    overlays = [
      inputs.alacritty-theme.overlays.default
      inputs.bible.overlays.default
      inputs.emacs-overlay.overlays.default
      (import "${root}/overlays/macos-bin.nix")
      nixpkgs-stable-overlay
      ((import "${root}/overlays/nixvim.nix") self)
      (final: prev: { nix-wallpaper = inputs.nix-wallpaper.packages.${prev.system}.default; })
      inputs.nur.overlays.default
      (import "${root}/overlays")
      (final: prev: { spicetify = inputs.spicetify.legacyPackages.${prev.system}; })
      (
        final: prev:
        if prev.stdenv.isDarwin then
          {
            zen = inputs.zen-browser-darwin.packages.${prev.system}.default;
          }
        else
          {
            zen = inputs.zen-browser-nixos.packages.${prev.system}.default;
          }
      )
    ];
  };
}
