{
  lib,
  writeShellApplication,
  ...
}:
writeShellApplication {
  name = "set-appearance";
  text = builtins.readFile ./set-appearance.sh;
  meta.description = "set light or dark mode for macOS";
  meta.platforms = lib.platforms.darwin;
}
