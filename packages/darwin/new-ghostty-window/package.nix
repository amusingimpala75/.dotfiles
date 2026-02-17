{
  lib,
  ripgrep,
  writeShellApplication,
  ...
}:
writeShellApplication {
  name = "new-ghostty-window";
  text = builtins.readFile ./new-ghostty-window.sh;
  meta = {
    description = "Create a new Ghostty window (NOT process) or open it if not yet open";
    platforms = lib.platforms.darwin;
  };
  runtimeInputs = [ ripgrep ];
}
