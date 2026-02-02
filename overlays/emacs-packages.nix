final: prev: {
  emacsPackagesFor =
    emacs:
    ((prev.emacsPackagesFor emacs).overrideScope (
      efinal: eprev: final.lib.packagesFromDirectoryRecursive {
        inherit (efinal) callPackage;
        directory = ../packages/emacs-packages;
      }
    ));
}
