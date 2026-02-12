{
  fetchzip,

  stdenvNoCC,
  ...
}:
let
  version = "1.4.1";
  hash = "sha256-b7N0fWPH+uxNoZdD2kYcEsJxIPxl/J6rCNvIlahu4s0=";
in
stdenvNoCC.mkDerivation {
  inherit version;
  pname = "WallP.exe";

  src = fetchzip {
    inherit hash;
    url = "https://github.com/LesFerch/WallP/releases/download/${version}/WallP.zip";
    stripRoot = false;
  };

  phases = [ "installPhase" ];

  installPhase = ''
    mkdir -p $out/bin
    cp $src/Windows/WallP.exe $out/bin/WallP.exe
    chmod +x $out/bin/WallP.exe
  '';

  meta = {
    mainProgram = "WallP.exe";
    description = "Way to set wallpaper in Windows";
    # specifically with WSL
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
    ];
  };
}
