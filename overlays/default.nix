final: prev: {
  ghostty-bin = final.callPackage ../packages/ghostty.nix { };
  whisky-bin = final.callPackage ../packages/whisky.nix { };
  xterm-24bit-terminfo = final.callPackage ../packages/xterm-24bit-terminfo.nix { };
  desktoppr = final.callPackage ../packages/desktoppr.nix { };
  wallp = final.callPackage ../packages/wallp.nix { };

  buildFennelPackage = final.callPackage ../packages/buildFennelPackage.nix { };

  my.emacs = final.callPackage ../packages/my-emacs { };
  my.launcher = final.callPackage ../packages/launcher.nix { };
  my.install = final.callPackage ../packages/install.nix { };

  scriptWrapper = final.callPackage ../packages/scriptWrapper.nix { };
  float_and = final.callPackage ../packages/float_and.nix { };
  ghostty_and = final.callPackage ../packages/ghostty_and.nix { };

  # I don't think this is how things are supposed to work
  # :TODO: move to lib?
  my.schemes = prev.callPackage ../packages/schemes.nix { };
  my.wallpapers = final.callPackage ../packages/wallpapers.nix { };
  my.base16-generators.emacs = final.callPackage ../packages/base16-emacs.nix { };
}
