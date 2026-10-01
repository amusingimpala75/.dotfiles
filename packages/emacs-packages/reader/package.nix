{
  fetchFromGitea,
  lib,
  melpaBuild,
  stdenv,

  emacs,
  pkg-config,
  mupdf-headless,
  ...
}:
let
  src = fetchFromGitea {
    domain = "codeberg.org";
    owner = "MonadicSheep";
    repo = "emacs-reader";
    rev = "424c84659b2882021700640eac9ed8f0995db0f6";
    hash = "sha256-XKLLX2/r8kTEIkkqGCmcGR/OU3/iXiZmwLjqVAZDX7s=";
  };
  core = stdenv.mkDerivation {
    inherit src;
    name = "emacs-reader-core";
    buildFlags = [ "CC=cc" ];
    nativeBuildInputs = [ pkg-config ];
    buildInputs = [
      mupdf-headless
      emacs
    ];
    installPhase = ''
      runHook preInstall

      install -Dm444 -t $out/lib/ render-core${stdenv.targetPlatform.extensions.sharedLibrary}

      runHook postInstall
    '';
    # Necessary on darwin (tries to use homebrew over nix for some reason)
    patches = [ ./0001-remove-pkg-config-disabling-block-just-always-use-it.patch ];
  };
in
melpaBuild {
  pname = "reader";
  version = "0-unstable-2026-09-30";
  inherit src;
  files = ''(:defaults "${lib.getLib core}/lib/render-core.*")'';
}
