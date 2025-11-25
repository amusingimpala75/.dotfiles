{
  fetchzip,

  stdenv,
  ...
}:
let
  pname = "WallP.exe";
  version = "1.2.0";
  url = "https://github.com/LesFerch/WallP/releases/download/1.2.0/WallP.zip";
  hash = "sha256-clY/gjMwSFB6XD2WcqYxU2xTD3zuFqhrOxQx44htv/0=";
in
stdenv.mkDerivation {
  inherit pname version;

  src = fetchzip {
    inherit url hash;
    stripRoot = false;
  };

  phases = [ "installPhase" ];

  installPhase = ''
    mkdir -p $out/bin
    cp $src/Windows/WallP.exe $out/bin/WallP.exe
    chmod +x $out/bin/WallP.exe
  '';

  meta = {
    # specifically with WSL
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
    ];
  };
}
