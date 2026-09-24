{
  fetchzip,
  lib,

  stdenvNoCC,
  ...
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "WallP.exe";
  version = "1.4.1";

  src = fetchzip {
    hash = "sha256-b7N0fWPH+uxNoZdD2kYcEsJxIPxl/J6rCNvIlahu4s0=";
    url = "https://github.com/LesFerch/WallP/releases/download/${finalAttrs.version}/WallP.zip";
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
    platforms = lib.platforms.linux;
  };
})
