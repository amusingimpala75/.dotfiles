{
  lib,
  scriptWrapper,
  ...
}:
scriptWrapper {
  path = ./unquarantine.sh;
  extraMeta = {
    description = "Unquarantine downloaded files";
    platforms = lib.platforms.darwin;
  };
}
