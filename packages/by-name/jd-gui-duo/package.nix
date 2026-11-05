{
  fetchFromGitHub,
  jdk25,
  lib,
  makeWrapper,
  maven,
  stdenv,
  ...
}:
maven.buildMavenPackage (finalAttrs: {
  pname = "jd-gui-duo";
  version = "2.0.116";

  src = fetchFromGitHub {
    owner = "nbauma109";
    repo = "jd-gui-duo";
    tag = finalAttrs.version;
    hash = "sha256-BnpV46LfdVvVo23i7LY50INREFeOT7QcWGSy4SSdUOQ=";
  };

  __structuredAttrs = true;
  strictDeps = true;

  mvnJdk = jdk25;
  mvnHash = "sha256-xXIF3K2+3HFSFxg68En5gzOkHDnQuWFIJYmtlq15X+c=";
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
    runHook preInstall

    mkdir -p $out/share/jd-gui-duo
    cp -r app/target/jd-gui-duo-app-${finalAttrs.version}.jar \
      app/src/main/resources/org/jd/gui/images/JDGUI.icns \
      app/target/lib/*.jar \
      $out/share/jd-gui-duo/
    makeWrapper ${lib.getExe jdk25} $out/bin/jd-gui-duo \
      --add-flags "-jar $out/share/jd-gui-duo/jd-gui-duo-app-${finalAttrs.version}.jar"
  ''
  + lib.optionalString stdenv.hostPlatform.isDarwin ''
    app="$out/Applications/JD-GUI Duo.app/Contents"
    mkdir -p "$app/MacOS" "$app/Resources"
    ln -s "$out/bin/jd-gui-duo" "$app/MacOS/jd-gui-duo"
    cp "$out/share/jd-gui-duo/JDGUI.icns" "$app/Resources/JDGUI.icns"
    cat > "$app/Info.plist" <<'EOF'
    <?xml version="1.0" encoding="UTF-8"?>
    <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
    <plist version="1.0">
    <dict>
      <key>CFBundleExecutable</key><string>jd-gui-duo</string>
      <key>CFBundleName</key><string>JD-GUI Duo</string>
      <key>CFBundleIdentifier</key><string>org.jd.gui.duo</string>
      <key>CFBundleIconFile</key><string>JDGUI.icns</string>
      <key>CFBundlePackageType</key><string>APPL</string>
      <key>CFBundleVersion</key><string>${finalAttrs.version}</string>
      <key>CFBundleShortVersionString</key><string>${finalAttrs.version}</string>
    </dict>
    </plist>
    EOF
  ''
  + ''
    runHook postInstall
  '';

  meta = {
    mainProgram = "jd-gui-duo";
    description = "A 2-in-1 JAVA decompiler based on JD-CORE v0 and v1 supporting 3rd party decompilers CFR, Procyon, Fernflower, Vineflower & Jadx.";
    license = lib.licenses.gpl3;
  };
})
