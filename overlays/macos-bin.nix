final: prev: prev.lib.optionalAttrs prev.stdenv.isDarwin {
  vlc = final.vlc-bin;
  ghostty = final.ghostty-bin;
}
