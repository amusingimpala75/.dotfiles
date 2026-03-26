{
  fetchFromGitHub,
  jdk25,
  lib,
  makeWrapper,
  maven,
  mkDarwinApplication ? null,
  stdenv,
  ...
}:
let
  version = "2.0.108";

  src = fetchFromGitHub {
    owner = "nbauma109";
    repo = "jd-gui-duo";
    rev = version;
    hash = "sha256-mvGzGrlQ883WbtaHDUuSVmUp9t6gRCAmet1SclPfM0k=";
  };

  pkg = maven.buildMavenPackage {
    pname = "jd-gui-duo";
    inherit version src;

    mvnJdk = jdk25;
    mvnHash = "sha256-YJz8cQZbZvMwJthYst4mCA1TAqhPupCpwC8yc5xgd30=";
    mvnParameters = lib.strings.join " " [
      "-pl"
      "app"
      "-am"
      "-DskipTests"
      "package"
      "org.apache.maven.plugins:maven-dependency-plugin:3.10.0:copy-dependencies"
      "-DincludeScope=runtime"
      "-DoutputDirectory=target/lib"
    ];

    nativeBuildInputs = [
      makeWrapper
    ];

    installPhase = ''
    mkdir -p $out/share/jd-gui-duo/lib
    cp -r app/target/jd-gui-duo-app-${version}.jar $out/share/jd-gui-duo/
    cp app/target/lib/*.jar $out/share/jd-gui-duo/lib/
    makeWrapper ${lib.getExe jdk25} $out/bin/jd-gui-duo \
      --add-flags "-cp $out/share/jd-gui-duo/lib/" \
      --add-flags "-jar $out/share/jd-gui-duo/jd-gui-duo-app-${version}.jar"
  '';

    meta = {
      mainProgram = "jd-gui-duo";
      description = "A 2-in-1 JAVA decompiler based on JD-CORE v0 and v1 supporting 3rd party decompilers CFR, Procyon, Fernflower, Vineflower & Jadx.";
      license = lib.licenses.gpl3;
    };
  };
in
if stdenv.isLinux || mkDarwinApplication == null
then pkg
else mkDarwinApplication {
  package = pkg;
  exeName = "jd-gui-duo";
  appName = "JD-GUI Duo";
  img = "${src}/app/src/main/resources/org/jd/gui/images/JDGUI.icns";
}
