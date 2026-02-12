{
  lib,
  ripgrep,
  writeShellApplication,
  ...
}:
writeShellApplication {
  name = "new-ghostty-window";
  text = builtins.readFile ./new-ghostty-window.sh;
  meta.platforms = lib.platforms.darwin;
  runtimeInputs = [ ripgrep ];
}
