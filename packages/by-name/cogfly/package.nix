{
  fetchFromGitHub,
  gradle_9,
  jdk25,
  lib,
  makeWrapper,
  stdenvNoCC,
  ...
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "cogfly";
  version = "1.2.5";

  src = fetchFromGitHub {
    owner = "Nix-main";
    repo = "Cogfly";
    rev = finalAttrs.version;
    hash = "sha256-noOe0Jyb53swzloY7e1TWI6oYzOpQclrTU38/R5mvXk=";
  };

  __darwinAllowLocalNetworking = true;

  nativeBuildInputs = [
    gradle_9
    jdk25
    makeWrapper
  ];

  # To update, run nix build .#cogfly.mitmCache.updateScript
  # [ .#cogfly.wrapped.mitmCache.updateScript on Darwin ]
  # and run the resuliting file. Note: you may need to pin
  # the port manually since it wasn't working for me one time,
  # no clue why
  mitmCache = gradle_9.fetchDeps {
    inherit (finalAttrs) pname;
    data = ./cogfly-deps.json;
  };

  gradleBuildTask = "shadowJar";

  doCheck = true;

  installPhase = ''
    mkdir -p $out/share/cogfly $out/bin
    cp build/libs/Cogfly-${finalAttrs.version}.jar $out/share/cogfly/
    makeWrapper ${lib.getExe jdk25} $out/bin/Cogfly \
      --add-flags "-jar $out/share/cogfly/Cogfly-${finalAttrs.version}.jar"
  ''
  + (lib.optionalString stdenvNoCC.hostPlatform.isDarwin ''
    mkdir -p $out/Applications/Cogfly.app/Contents/MacOS $out/Applications/Cogfly.app/Contents/Resources
    cp resources/mac/Info.plist $out/Applications/Cogfly.app/Contents/
    cp resources/icons/icon.icns $out/Applications/Cogfly.app/Contents/Resources/Cogfly.icns
    cp $out/bin/Cogfly $out/Applications/Cogfly.app/Contents/MacOS
  '')
  + (lib.optionalString stdenvNoCC.hostPlatform.isLinux ''
    mkdir -p $out/share/applications
    cp resources/linux/Cogfly.desktop $out/share/applications/
  '');

  meta = {
    mainProgram = "cogfly";
    description = "Cogfly is a mod loader for Silksong";
    license = lib.licenses.asl20;
    platforms = lib.platforms.all;
  };
})
