{
  lib,
  writeShellApplication,
  ...
}:
writeShellApplication {
  name = "get-win-sid";
  text = builtins.readFile ./get-win-sid.sh;
  meta.description = "get the windows SID of a WSL user";
  meta.platforms = lib.platforms.linux;
}
