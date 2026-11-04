{
  fetchFromGitHub,
  lib,
  stdenvNoCC,
  nix-update-script,
}:
stdenvNoCC.mkDerivation {
  pname = "pi-telegram";
  version = "0-unstable-2026-04-03";

  src = fetchFromGitHub {
    owner = "badlogic";
    repo = "pi-telegram";
    rev = "cb34008460b6c1ca036d92322f69d87f626be0fc";
    hash = "sha256-2Gvr3AogpEHkmGkHetVfaPW9VHyMH9TZaK3swKbvQCw=";
  };

  patches = [
    ./fix-agent-dir.patch
  ];

  installPhase = ''
    runHook preInstall

    cp -r . $out

    runHook postInstall
  '';

  passthru.updateScript = nix-update-script {
    attrPath = "pi-telegram";
    extraArgs = [
      "--flake"
      "--version=branch"
    ];
  };

  meta.platforms = lib.platforms.all;
}
