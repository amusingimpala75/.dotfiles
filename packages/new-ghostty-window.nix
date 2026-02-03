{
  lib,
  ripgrep,
  scriptWrapper,
  ...
}:
scriptWrapper {
  path = ./new-ghostty-window.sh;
  deps = [ ripgrep ];
  extraMeta = {
    platforms = lib.platforms.darwin;
  };
}
