{
  lib,
  scriptWrapper,
  ...
}:
scriptWrapper {
  path = ./get-win-sid.sh;
  extraMeta = {
    description = "get the windows SID of a WSL user";
    platforms = lib.platforms.linux;
  };
}
