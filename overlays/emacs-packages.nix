final: prev: {
  emacsPackagesFor = emacs: ((prev.emacsPackagesFor emacs).overrideScope (efinal: eprev: {
    nnnrss = final.callPackage ../packages/emacs/nnnrss.nix { };
    org-modern-indent = final.callPackage ../packages/emacs/org-modern-indent.nix { };
    toggleterm = final.callPackage ../packages/emacs/toggleterm.nix { };
    reader = final.callPackage ../packages/emacs/reader.nix { };
    page-view = final.callPackage ../packages/emacs/page-view.nix { };
    org-karthik = final.callPackage ../packages/emacs/org-karthik.nix { };
  }));
}
