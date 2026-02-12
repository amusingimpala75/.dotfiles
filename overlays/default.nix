final: prev: {
  brogue-ce-darwin = final.mkDarwinApplication {
    package = final.brogue-ce;
    exeName = "brogue-ce";
    appName = "Brogue";
    img = "${final.brogue-ce}/share/icons/hicolor/256x256/apps/brogue-ce.png";
  };
  desktoppr = final.callPackage ../packages/desktoppr.nix { };
  wallp = final.callPackage ../packages/wallp.nix { };
  infat = final.callPackage ../packages/infat.nix { };
  brightness = final.callPackage ../packages/brightness.nix { };
  unquarantine = final.callPackage ../packages/unquarantine.nix { };
  screen-saver = final.callPackage ../packages/screen-saver.nix { };
  run-ntfy-when-done = final.callPackage ../packages/run-ntfy-when-done.nix { };
  play-audio = final.callPackage ../packages/play-audio.nix { };
  get-win-sid = final.callPackage ../packages/get-win-sid.nix { };
  set-appearance = final.callPackage ../packages/set-appearance.nix { };

  mrpack-install = prev.mrpack-install.overrideAttrs (prev: {
    doCheck = !final.stdenv.isDarwin;
  });

  buildFennelPackage = final.callPackage ../packages/buildFennelPackage.nix { };
  fennelToLua = final.callPackage ../packages/fennelToLua.nix { };
  mkDarwinApplication = final.callPackage ../packages/mkDarwinApplication.nix { };

  my.emacs = final.callPackage ../packages/emacs { };
  my.install = final.callPackage ../packages/install.nix { };

  float_and = final.callPackage ../packages/float_and.nix { };
  ghostty_and = final.callPackage ../packages/ghostty_and.nix { };

  # I don't think this is how things are supposed to work
  # :TODO: move to lib?
  my.schemes = prev.callPackage ../packages/schemes.nix { };
  my.wallpapers = final.callPackage ../packages/wallpapers.nix { };
  my.base16-generators.emacs = final.callPackage ../packages/base16-emacs.nix { };

  my.new-ghostty-window = final.callPackage ../packages/new-ghostty-window.nix { };
}
