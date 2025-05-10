{ inputs, lib, root, ... }:
let
  nixpkgs-stable-overlay = (final: prev: if prev.stdenv.isDarwin then {
    stable = inputs.nixpkgs-stable-darwin.legacyPackages.${prev.system};
  } else {
    stable = inputs.nixpkgs-stable-nixos.legacyPackages.${prev.system};      
  });
in {
  config.nixpkgs = {
    config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
      "dwarf-fortress"
      "gaoptout" # Google Analytics Opt-Out Firefox Addon
      "spacefox-theme"
      "spotify"
      "untrap-for-youtube"
    ];
    overlays = [
      inputs.alacritty-theme.overlays.default
      inputs.bible.overlays.default
      inputs.emacs-overlay.overlays.default
      (import "${root}/overlays/macos-bin.nix")
      nixpkgs-stable-overlay
      (final: prev: { nix-wallpaper = inputs.nix-wallpaper.packages.${prev.system}.default; })
      inputs.nur.overlays.default
      (import "${root}/overlays")
      (final: prev: { spicetify = inputs.spicetify.legacyPackages.${prev.system}; })
      (final: prev: if prev.stdenv.isDarwin then {
        zen = inputs.zen-browser-darwin.packages.${prev.system}.default;
      } else {
        zen = inputs.zen-browser-nixos.packages.${prev.system}.default;
      })
      (final: prev: { sbarlua = inputs.sbarlua-nixpkgs.legacyPackages.${prev.system}.sbarlua.override { lua54Packages = final.lua54Packages; }; })
    ];
  };
}
