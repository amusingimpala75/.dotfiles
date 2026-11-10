{
  fetchFromGitea,
  lib,
  melpaBuild,
  nix-update-script,
  stdenv,

  emacs,
  pkg-config,
  mupdf-headless,
  ...
}:
let
  version = "0.4.0";
  src = fetchFromGitea {
    domain = "codeberg.org";
    owner = "MonadicSheep";
    repo = "emureader";
    tag = version;
    hash = "sha256-Ot0f0eWLJEv/bka7guUjL1HcqLDTZUUxxdSK0I/ogNY=";
  };
  core = stdenv.mkDerivation {
    inherit src version;
    pname = "emureader-core";
    buildFlags = [
      "CC=cc"
      "USE_PKGCONFIG=yes"
    ];
    nativeBuildInputs = [ pkg-config ];
    buildInputs = [
      mupdf-headless
      emacs
    ];
    installPhase = ''
      runHook preInstall

      install -Dm444 -t $out/lib/ emureader-dyn${stdenv.targetPlatform.extensions.sharedLibrary}

      runHook postInstall
    '';
  };
in
melpaBuild {
  pname = "emureader";
  inherit src version;

  files = ''(:defaults "${lib.getLib core}/lib/emureader-dyn${stdenv.targetPlatform.extensions.sharedLibrary}")'';
}
