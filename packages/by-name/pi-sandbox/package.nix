{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  fetchPnpmDeps,
  pnpm_10,
  pnpmBuildHook,
  pnpmConfigHook,
}:
let
  pnpm = pnpm_10;
in
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "pi-sandbox";
  version = "0.7.1";
  __structuredAttrs = true;
  strictDeps = true;

  src = fetchFromGitHub {
    owner = "carderne";
    repo = "pi-sandbox";
    tag = "v${finalAttrs.version}";
    hash = "sha256-i9hC0xvzB3j80hwfQ41llLLnVg0j82kVh+y7fgpkGLQ=";
  };

  pnpmDeps = fetchPnpmDeps {
    inherit (finalAttrs) pname src;
    inherit pnpm;
    hash = "sha256-AG27LaE8sNXbScB+eIWd47mAnaksmtBgPD9FZyocJJE=";
    fetcherVersion = 4;
  };

  nativeBuildInputs = [
    pnpm
    pnpmBuildHook
    pnpmConfigHook
  ];

  dontPnpmBuild = true;

  installPhase = ''
    runHook preInstall

    # install -d $out/lib/node_modules
    cp -r . $out

    runHook postInstall
  '';

  meta = {
    description = "OS-level sandboxing for pi with interactive permission prompts";
    homepage = "https://github.com/carderne/pi-sandbox";
    changelog = "https://github.com/carderne/pi-sandbox/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;
    mainProgram = "pi-sandbox";
    platforms = lib.platforms.all;
  };
})
