{
  fetchFromGitHub,
  gradle_9,
  jdk25,
  lib,
  makeWrapper,
  mkDarwinApplication,
  stdenvNoCC,
  ...
}:
(
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
      cp build/libs/Cogfly-${finalAttrs.version}.jar resources/icons/icon.icns $out/share/cogfly/
      makeWrapper ${lib.getExe jdk25} $out/bin/cogfly \
        --add-flags "-jar $out/share/cogfly/Cogfly-${finalAttrs.version}.jar"
    '';

    meta = {
      mainProgram = "cogfly";
      description = "Cogfly is a mod loader for Silksong";
      license = lib.licenses.asl20;
      platforms = lib.platforms.all;
    };
  })
  |> (
    if stdenvNoCC.hostPlatform.isLinux then
      package: package
    else
      package:
      mkDarwinApplication {
        inherit package;
        exeName = "cogfly";
        appName = "Cogfly";
        img = "${package}/share/cogfly/icon.icns";
      }
  )
)
