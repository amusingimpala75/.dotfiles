final: prev: {
  brightness = final.callPackage ../packages/brightness.nix { };
  float_and = final.callPackage ../packages/float_and.nix { };
  ghostty_and = final.callPackage ../packages/ghostty_and.nix { };
  new-ghostty-window = final.callPackage ../packages/new-ghostty-window.nix { };
  run-ntfy-when-done = final.callPackage ../packages/run-ntfy-when-done.nix { };
  screen-saver = final.callPackage ../packages/screen-saver.nix { };
  set-appearance = final.callPackage ../packages/set-appearance.nix { };
  unquarantine = final.callPackage ../packages/unquarantine.nix { };
}
