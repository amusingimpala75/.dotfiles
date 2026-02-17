{
  lib,
  writeShellApplication,
  ...
}:
writeShellApplication {
  name = "ghostty_and";
  text = ''open -na Ghostty --args --command="$1" "$2"'';
  meta.platforms = lib.platforms.darwin;
}
