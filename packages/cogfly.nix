{
  fetchFromGitHub,
  gradle_9,
  jdk25,
  lib,
  makeWrapper,
  mkDarwinApplication,
  stdenv,
  ...
}:
let
  version = "1.1.2";

  src = fetchFromGitHub {
    owner = "Nix-main";
    repo = "Cogfly";
    rev = version;
    hash = "sha256-49pBeR5I4iqIaIgK5wsMQt+pCXYJOYEwjAsgp54pYJk=";
  };

  pkg = stdenv.mkDerivation {
    pname = "cogfly";
    inherit version src;

    __darwinAllowLocalNetworking = true;

    nativeBuildInputs = [ gradle_9 jdk25 makeWrapper ];

    mitmCache = gradle_9.fetchDeps {
      inherit pkg;
      data = ./cogfly-deps.json;
    };

    gradleBuildTask = "shadowJar";

    doCheck = true;

    installPhase = ''
    mkdir -p $out/share/cogfly $out/bin
    cp build/libs/Cogfly-${version}.jar $out/share/cogfly/
    makeWrapper ${lib.getExe jdk25} $out/bin/cogfly \
      --add-flags "-jar $out/share/cogfly/Cogfly-${version}.jar"
    '';

    # TODO: package app with proper macOS app
    meta = {
      mainProgram = "cogfly";
      description = "Cogfly is a mod loader for Silksong";
      license = lib.licenses.asl20;
    };
  };
  darwin-pkg = mkDarwinApplication {
    package = pkg;
    exeName = "cogfly";
    appName = "Cogfly";
    img = "${src}/icons/icon.icns";
  };
in
if stdenv.isDarwin then darwin-pkg else pkg
