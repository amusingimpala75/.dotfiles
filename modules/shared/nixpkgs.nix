{ inputs, root, ... }:
let
  nixpkgs-stable-overlay = (final: prev: if prev.stdenv.isDarwin then {
    stable = inputs.nixpkgs-stable-darwin.legacyPackages.${prev.system};
  } else {
    stable = inputs.nixpkgs-stable-nixos.legacyPackages.${prev.system};      
  });
in {
  config.nixpkgs = {
    config.allowUnfree = true;
    overlays = [
      inputs.alacritty-theme.overlays.default
      inputs.bible.overlays.default
      inputs.emacs-overlay.overlays.default
      (import "${root}/overlays/macos-bin.nix")
      nixpkgs-stable-overlay
      (final: prev: { nix-wallpaper = inputs.nix-wallpaper.packages.${prev.system}.default; })
      inputs.nur.overlays.default
      (import "${root}/overlays")
      inputs.sbarlua.overlay
      (final: prev: { spicetify = inputs.spicetify.legacyPackages.${prev.system}; })
    ];
  };
}
