final: prev: {
  ghostty-bin = final.callPackage ../packages/ghostty.nix { };
  whisky-bin = final.callPackage ../packages/whisky.nix { };

  my.emacs = final.callPackage ../packages/my-emacs { };
  my.launcher = final.callPackage ../packages/launcher.nix { };
  my.install = final.callPackage ../packages/install.nix { };

  scriptWrapper = final.callPackage ../packages/scriptWrapper.nix { };
  float_and = final.callPackage ../packages/float_and.nix { };
  ghostty_and = final.callPackage ../packages/ghostty_and.nix { };
}
