{
  lib,
  writeShellApplication,
  ...
}:
writeShellApplication {
  name = "screen-saver";
  text = "open /System/Library/CoreServices/ScreenSaverEngine.app";
  meta.description = "Launch macOS Screen Saver from command line";
  meta.platforms = lib.platforms.darwin;
}

