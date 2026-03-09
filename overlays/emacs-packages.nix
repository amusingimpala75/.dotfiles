final: prev: {
  emacsPackagesFor =
    emacs:
    ((prev.emacsPackagesFor emacs).overrideScope (
      efinal: _:
      final.lib.packagesFromDirectoryRecursive {
        inherit (efinal) callPackage;
        directory = ../packages/emacs-packages;
      }
    ));
}
