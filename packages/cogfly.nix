{
  fetchFromGitHub,
  gradle_9,
  jdk25,
  lib,
  makeWrapper,
  stdenv,
  ...
}:
let
  version = "1.1.2";
  self = stdenv.mkDerivation {
    pname = "cogfly";
    inherit version;

    src = fetchFromGitHub {
      owner = "Nix-main";
      repo = "Cogfly";
      rev = version;
      hash = "sha256-49pBeR5I4iqIaIgK5wsMQt+pCXYJOYEwjAsgp54pYJk=";
    };

    __darwinAllowLocalNetworking = true;

    nativeBuildInputs = [ gradle_9 jdk25 makeWrapper ];

    mitmCache = gradle_9.fetchDeps {
      pkg = self;
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
  };
in
self
