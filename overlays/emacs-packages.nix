final: prev: {
  emacsPackagesFor = emacs: ((prev.emacsPackagesFor emacs).overrideScope (efinal: eprev: {
    nnnrss = efinal.callPackage ../packages/emacs/nnnrss.nix { };
    org-modern-indent = efinal.callPackage ../packages/emacs/org-modern-indent.nix { };
    toggleterm = efinal.callPackage ../packages/emacs/toggleterm.nix { };
    reader = efinal.callPackage ../packages/emacs/reader.nix { };
    page-view = efinal.callPackage ../packages/emacs/page-view.nix { };
    org-karthik = efinal.callPackage ../packages/emacs/org-karthik.nix { };
  }));
}
