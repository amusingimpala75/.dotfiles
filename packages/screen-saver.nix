{
  lib,
  scriptWrapper,
  ...
}:
scriptWrapper {
  path = ./screen-saver.sh;
  extraMeta = {
    description = "Launch macOS Screen Saver from command line";
    platforms = lib.platforms.darwin;
  };
}
