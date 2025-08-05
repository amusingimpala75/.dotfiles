{
  fetchzip,
  lib,
  stdenv,
  ...
}:
# TODO actually build the package here
stdenv.mkDerivation {
  pname = "infat";
  version = "2.4.0";

  src = fetchzip {
    url = "https://github.com/philocalyst/infat/releases/download/v2.4.0/infat-arm64-apple-macos.tar.gz";
    hash = "sha256-PbtEcDS9cB50vCs0sSzhj2iJ93d4PF/bhswv2ysGFbM=";
  };

  installPhase = ''
    mkdir -p $out/bin/
    cp $src/infat $out/bin/
  '';

  meta = {
    platforms = lib.platforms.darwin;
  };
}
