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
maven.buildMavenPackage (finalAttrs: {
  pname = "jd-gui-duo";
  version = "2.0.114";

  src = fetchFromGitHub {
    owner = "nbauma109";
    repo = "jd-gui-duo";
    rev = finalAttrs.version;
    hash = "sha256-AahkB8PfsFT8q/IrbrX7qLVZpO912XEn598tjhVX/Qg=";
  };

  mvnJdk = jdk25;
  mvnHash = "sha256-DWwXzdngSgsl7qicGdH1ElMQvef6uFs+L+iVoN7FgfY=";
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
    mkdir -p $out/share/jd-gui-duo
    cp -r app/target/jd-gui-duo-app-${finalAttrs.version}.jar \
      app/src/main/resources/org/jd/gui/images/JDGUI.icns \
      app/target/lib/*.jar \
      $out/share/jd-gui-duo/
    makeWrapper ${lib.getExe jdk25} $out/bin/jd-gui-duo \
      --add-flags "-jar $out/share/jd-gui-duo/jd-gui-duo-app-${finalAttrs.version}.jar"
  '';

  meta = {
    mainProgram = "jd-gui-duo";
    description = "A 2-in-1 JAVA decompiler based on JD-CORE v0 and v1 supporting 3rd party decompilers CFR, Procyon, Fernflower, Vineflower & Jadx.";
    license = lib.licenses.gpl3;
  };
})
|> (
  if stdenv.hostPlatform.isLinux then
    lib.id
  else
    package:
    mkDarwinApplication {
      inherit package;
      exeName = "jd-gui-duo";
      appName = "JD-GUI Duo";
      img = "${package}/share/jd-gui-duo/JDGUI.icns";
    }
)
