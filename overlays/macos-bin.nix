final: prev: prev.lib.optionalAttrs prev.stdenv.isDarwin {
  vlc = final.vlc-bin;
  firefox = final.firefox-bin;
  ghostty = final.ghostty-bin;
}
