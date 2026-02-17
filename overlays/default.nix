final: prev: {
  # Vendored packages
  cogfly = final.callPackage ../packages/cogfly.nix { };
  wallpapers = final.callPackage ../packages/wallpapers.nix { };

  # Fixes
  mrpack-install = prev.mrpack-install.overrideAttrs (prev: {
    doCheck = !final.stdenv.isDarwin;
  });

  # Custom Stuff
  custom-emacs = final.callPackage ../packages/emacs { };
  install = final.callPackage ../packages/install.nix { };
  play-audio = final.callPackage ../packages/play-audio.nix { };

  # Builders / lib functions
  base1624schemes = prev.callPackage ../packages/lib/schemes.nix { };
  buildFennelPackage = final.callPackage ../packages/lib/buildFennelPackage.nix { };
  fennelToLua = final.callPackage ../packages/lib/fennelToLua.nix { };
  fetchMTGWallpaper = final.callPackage ../packages/lib/fetchMTGWallpaper.nix { };
  mkDarwinApplication = final.callPackage ../packages/lib/mkDarwinApplication.nix { };
  base16-generators.emacs = final.callPackage ../packages/lib/mkBase16EmacsTheme.nix { };
}
