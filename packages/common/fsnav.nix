{
  freetype,
  fetchFromGitHub,
  libjpeg,
  pkg-config,
  stdenv,
}:

stdenv.mkDerivation (finalAttrs: {
  name = "fsnav";
  version = "0.1";

  src = fetchFromGitHub {
    owner = "jtsiomb";
    repo = "fsnav";
    tag = "v${finalAttrs.version}";
    hash = "sha256-Bt1QRqtJkVFR1uMzmB3OUyqyzUyJdQyQdbMOfMyWJOc=";
  };

  makeFlags = [
    "CC=${stdenv.cc.targetPrefix}cc"
    "CXX=${stdenv.cc.targetPrefix}c++"
    "PREFIX=$(out)"
  ];

  preInstall = ''
    mkdir -p $out/bin
  '';

  buildInputs = [
    freetype
    libjpeg
  ];

  nativeBuildInputs = [
    pkg-config
  ];

  meta = {
    mainProgram = "fsnav";
  };
})
