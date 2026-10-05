{
  fetchFromGitHub,
  lib,
  stdenvNoCC,
}:
stdenvNoCC.mkDerivation {
  name = "pi-minimal-footer";
  version = "0-unstable-2026-09-26";

  src = fetchFromGitHub {
    owner = "ogulcancelik";
    repo = "pi-extensions";
    rev = "373a8cf735e66792dae8b096bc62f8d5cf7693a8";
    hash = "sha256-njwAfX8NW0cXp2c4Rfh0xmrGwd7isHqH5jD2/z8LTqM=";
  };

  patches = [ ./fix-agent-dir.patch ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/extensions
    cat packages/pi-minimal-footer/index.ts >> $out/extensions/pi-minimal-footer.ts
    cat > $out/package.json <<'EOF'
    {
      "name": "pi-minimal-footer",
      "private": true,
      "pi": {
        "extensions": ["./extensions/pi-minimal-footer.ts"]
      }
    }
    EOF

    runHook postInstall
  '';

  meta.platforms = lib.platforms.all;
}
