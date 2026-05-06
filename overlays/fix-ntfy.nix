final: prev: {
  ntfy-sh = prev.ntfy-sh.overrideAttrs (old: {
    patches = (old.patches or [ ]) ++ [
      (final.fetchurl {
        url = "https://github.com/ShipItAndPray/ntfy/commit/82e9dfe8f160e8c48302b13ad3aab812b8482fa6.patch";
        hash = "sha256-n+OCrfVTHmjKyZCVsqqOgog50Fbl781daqcow378WH0=";
      })
    ];
  });
}
