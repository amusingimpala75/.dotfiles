{
  lib,
  writeShellApplication,
  ...
}:
writeShellApplication {
  name = "ghostty_and";
  text = ''open -na Ghostty --args --command="$1" "$2"'';
  meta = {
    description = "Launch Ghostty running the following command";
    platforms = lib.platforms.darwin;
  };
}
