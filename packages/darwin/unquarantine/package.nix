{
  lib,
  writeShellApplication,
  ...
}:
writeShellApplication {
  name = "unquarantine";
  text = builtins.readFile ./unquarantine.sh;
  meta.description = "Unquarantine downloaded files";
  meta.platforms = lib.platforms.darwin;
}
