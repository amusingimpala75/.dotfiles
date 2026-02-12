{
  lib,
  scriptWrapper,
  ...
}:
scriptWrapper {
  path = ./set-appearance.sh;
  extraMeta = {
    description = "set light or dark mode for macOS";
    platforms = lib.platforms.darwin;
  };
}
