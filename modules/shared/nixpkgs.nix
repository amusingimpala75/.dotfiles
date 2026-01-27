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
      "slack"
      "spacefox-theme"
      "spotify"
      "youtube-recommended-videos"
      "zoom"
    ];

  import-nixpkgs =
    np: final: prev:
    import np {
      system = prev.stdenv.hostPlatform.system;
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
      self.overlays.default
      inputs.emacs-overlay.overlays.default
      self.overlays.emacs-packages
      self.overlays.macos-bin
      nixpkgs-stable-overlay
      self.overlays.nixvim
      (final: prev: {
        nix-wallpaper = inputs.nix-wallpaper.packages.${final.stdenv.hostPlatform.system}.default;
      })
      inputs.nur.overlays.default
      self.overlays.oh-my-opencode
      (final: prev: { spicetify = inputs.spicetify.legacyPackages.${final.stdenv.hostPlatform.system}; })
    ];
  };
}
