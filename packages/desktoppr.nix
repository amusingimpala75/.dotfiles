{
  fetchzip,

  lib,
  stdenv,
  ...
}:
let
  name = "desktoppr";
  url = "https://github.com/scriptingosx/desktoppr/releases/download/v0.5/desktoppr-0.5-218.zip";
  hash = "sha256-JHnQS4ZL0GC4shBcsKtmPOSFBY6zLSV/IAFRb4+A++Q=";
in
stdenv.mkDerivation {
  inherit name;
  pname = name;

  src = fetchzip {
    inherit url hash;
  };

  phases = [ "installPhase" ];

  installPhase = ''
    mkdir -p $out/bin
    cp $src/desktoppr $out/bin
  '';

  meta = {
    description = "Command-line utility to set wallpaper on macOS";
    platforms = lib.platforms.darwin;
  };
}
