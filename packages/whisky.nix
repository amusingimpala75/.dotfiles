# This does NOT install WhiskyWine
# TODO: remedy ^
{
  fetchzip,
  stdenv,
  ...
}:
let
  version = "v2.3.4";
  url = "https://data.getwhisky.app/Releases/${version}/Whisky.zip";
  sha256 = "sha256-6cvQjbdRH0W5/DGLIoZRDniZGQeLEK5sr6vcQueygnI=";
in
stdenv.mkDerivation {
  inherit version;
  pname = "Whisky";

  outputs = [ "out" ];

  sourceRoot = ".";
  phases = [ "unpackPhase" "installPhase" ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/Applications
    cp -r . $out/Applications/
    mv $out/Applications/Whisky.zip $out/Applications/Whisky.app

    runHook postInstall
  '';

  src = fetchzip {
    inherit url sha256;
    name = "Whisky.zip";
  };

  meta = {
    description = "A modern Wine wrapper for macOS built with SwiftUI";
    homepage = "https://getwhisky.app";
  };
}
