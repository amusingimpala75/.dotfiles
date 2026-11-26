{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  ninja,
  nix-update-script,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "kapitsa";
  version = "0.2.40";

  src = fetchFromGitHub {
    owner = "nace-ai";
    repo = "kapitsa";
    tag = "v${finalAttrs.version}";
    hash = "sha256-DmAtzPS3Z1PKGpk8Sa16N1nqyEZGj/+CyrhlQZ01Auo=";
  };

  __structuredAttrs = true;
  strictDeps = true;

  nativeBuildInputs = [
    cmake
    ninja
  ];

  cmakeFlags = [ "-DKAPITSA_GIT=${finalAttrs.src.rev}" ];
  # Upstream's default target also builds development and GPU test tools.
  ninjaFlags = [ "kapitsa" ];

  installPhase = ''
    runHook preInstall
    install -Dm755 kapitsa "$out/bin/kapitsa"
    install -Dm644 ../LICENSE "$out/share/licenses/kapitsa/LICENSE"
    install -Dm644 ../THIRD_PARTY_NOTICES "$out/share/licenses/kapitsa/THIRD_PARTY_NOTICES"
    runHook postInstall
  '';

  passthru.updateScript = nix-update-script {
    attrPath = "kapitsa";
    extraArgs = [ "--flake" ];
  };

  meta = {
    description = "Apple Silicon inference engine with OpenAI and Anthropic compatible APIs";
    homepage = "https://github.com/nace-ai/kapitsa";
    license = lib.licenses.asl20;
    platforms = [ "aarch64-darwin" ];
    mainProgram = "kapitsa";
  };
})
