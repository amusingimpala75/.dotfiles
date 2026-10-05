{
  lib,
  stdenvNoCC,
  fetchurl,
  unzip,
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "lancet-nano-model";
  version = "0.4.3";

  src = fetchurl {
    url = "https://github.com/TannerMidd/LANCET-model/releases/download/v${finalAttrs.version}/lancet-v${finalAttrs.version}-nano-cpu-int8.zip";
    hash = "sha256-dbcwer8WqcY4Br5qaqiOmxjMRjzd9+T9xsm44n1MmFw=";
  };

  __structuredAttrs = true;
  strictDeps = true;
  nativeBuildInputs = [ unzip ];
  dontBuild = true;

  installPhase = ''
    runHook preInstall

    # Preserve the complete release, including model licenses, notices and model card.
    mkdir -p "$out"
    cp -r . "$out/"
    test -f "$out/model/encoder-int8.onnx"

    runHook postInstall
  '';

  meta = {
    description = "LANCET Nano CPU INT8 command-risk classifier model";
    homepage = "https://github.com/TannerMidd/LANCET-model";
    license = [
      lib.licenses.asl20
      lib.licenses.bsd3
    ];
    platforms = lib.platforms.all;
  };
})
