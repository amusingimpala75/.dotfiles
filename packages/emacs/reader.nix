{
  emacs,
  emacsPackagesFor,
  fetchFromGitea,
  lib,
  stdenv,

  pkg-config,
  mupdf-headless,
  ...
}:
let
  epkgs = emacsPackagesFor emacs;
  src = fetchFromGitea {
    domain = "codeberg.org";
    owner = "divyaranjan";
    repo = "emacs-reader";
    rev = "5f80aa8ed2e13772174ef2517ad75c617d44bd4e";
    hash = "sha256-BJM69NHfq6MJJE3UG1442ttPBGBAsn3jxZcpP+LtmxQ=";
  };
  core = stdenv.mkDerivation {
    inherit src;
    name = "emacs-reader-core";
    buildFlags = [ "CC=cc" ];
    nativeBuildInputs = [ pkg-config ];
    buildInputs = [ mupdf-headless ];    
    installPhase = ''
      runHook preInstall

      install -Dm444 -t $out/lib/ render-core${stdenv.targetPlatform.extensions.sharedLibrary}

      runHook postInstall
    '';
    patches = [ ./0001-remove-pkg-config-disabling-block-just-always-use-it.patch ];
  };
in
(epkgs.melpaBuild {
  pname = "reader";
  version = "20251208";
  inherit src;
  files = ''(:defaults "${lib.getLib core}/lib/render-core.*")'';
})
