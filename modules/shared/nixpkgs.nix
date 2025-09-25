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
      "copilot-language-server"
      "dwarf-fortress"
      "gaoptout" # Google Analytics Opt-Out Firefox Addon
      "modrinth-app" # it for some reason has both gpl3+ and unfree redistributable?
      "modrinth-app-unwrapped"
      "slack"
      "spacefox-theme"
      "spotify"
      "youtube-recommended-videos"
      "zoom"
    ];

  import-nixpkgs =
    np: final: prev:
    import np {
      system = prev.system;
      config.allowUnfreePredicate = unfree-predicate;
    };
  nixpkgs-stable-overlay = final: prev: {
    stable =
      import-nixpkgs inputs."nixpkgs-stable-${if prev.stdenv.isDarwin then "darwin" else "nixos"}" final
        prev;
  };
in
{
  config.nixpkgs = {
    config.allowUnfreePredicate = unfree-predicate;
    overlays = [
      inputs.alacritty-theme.overlays.default
      inputs.bible.overlays.default
      (final: prev: { bleeding = import-nixpkgs inputs.nixpkgs-bleeding final prev; })
      (final: prev: { emacs = (import-nixpkgs inputs.nixpkgs-darwin-xwidgets final prev).emacs; })
      inputs.emacs-overlay.overlays.default
      (import "${root}/overlays/macos-bin.nix")
      nixpkgs-stable-overlay
      ((import "${root}/overlays/nixvim.nix") self)
      (final: prev: { nix-wallpaper = inputs.nix-wallpaper.packages.${prev.system}.default; })
      inputs.nur.overlays.default
      (import "${root}/overlays")
      (final: prev: { spicetify = inputs.spicetify.legacyPackages.${prev.system}; })
    ];
  };
}
