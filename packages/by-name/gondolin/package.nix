{
  lib,
  fetchFromGitHub,
  fetchPnpmDeps,
  makeWrapper,
  nodejs_22,
  pnpm_12,
  pnpmBuildHook,
  pnpmConfigHook,
  qemu,
  stdenvNoCC,
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "gondolin";
  version = "0.13.0";

  src = fetchFromGitHub {
    owner = "earendil-works";
    repo = "gondolin";
    tag = "v${finalAttrs.version}";
    hash = "sha256-zxcP/S9Z4ofke1aligdqEYEEUwyjywyphXgoqyV/Mfs=";
  };

  pnpmDeps = fetchPnpmDeps {
    inherit (finalAttrs) pname src;
    pnpm = pnpm_12;
    hash =
      if stdenvNoCC.hostPlatform.isLinux then
        "sha256-8zZYuHJ21i7ise6Yb7rFztyFDydnGT1o95jPFxVDcaE="
      else
        "sha256-RgrN6vYlcoNmG6NsQUcQhP40ipboTuEubQaoN3se+Rw=";
    fetcherVersion = 4;
  };

  nativeBuildInputs = [
    makeWrapper
    nodejs_22
    pnpm_12
    pnpmBuildHook
    pnpmConfigHook
  ];

  pnpmWorkspaces = [ "@earendil-works/gondolin" ];

  __structuredAttrs = true;
  strictDeps = true;

  installPhase = ''
    runHook preInstall

    install -d $out/bin $out/lib/node_modules
    pnpm --filter @earendil-works/gondolin deploy --prod --ignore-scripts $out/lib/node_modules/gondolin
    makeWrapper ${nodejs_22}/bin/node $out/bin/gondolin \
      --add-flags "$out/lib/node_modules/gondolin/dist/bin/gondolin.js" \
      --prefix PATH : ${lib.makeBinPath [ qemu ]}

    runHook postInstall
  '';

  passthru.pi-extension = stdenvNoCC.mkDerivation {
    pname = "gondolin-pi-extension";
    inherit (finalAttrs) version;

    dontUnpack = true;
    dontConfigure = true;
    dontBuild = true;

    __structuredAttrs = true;
    strictDeps = true;

    installPhase = ''
      runHook preInstall

      install -d $out/extensions $out/node_modules/@earendil-works
      cat > $out/extensions/pi-gondolin.ts <<'EOF'
      process.env.PATH = "${lib.makeBinPath [ qemu ]}:" + (process.env.PATH ?? "");
      EOF
      cat ${finalAttrs.src}/host/examples/pi-gondolin.ts >> $out/extensions/pi-gondolin.ts
      ln -s ${finalAttrs.finalPackage}/lib/node_modules/gondolin \
        $out/node_modules/@earendil-works/gondolin
      cat > $out/package.json <<'EOF'
      {
        "name": "gondolin-pi-extension",
        "private": true,
        "pi": {
          "extensions": ["./extensions/pi-gondolin.ts"]
        }
      }
      EOF

      runHook postInstall
    '';

    meta = {
      description = "Pi extension that runs Pi tools in a Gondolin micro-VM";
      homepage = "https://github.com/earendil-works/gondolin";
      license = lib.licenses.asl20;
      platforms = lib.platforms.linux ++ lib.platforms.darwin;
    };
  };

  meta = {
    description = "Local Linux micro-VMs with programmable network and filesystem control";
    homepage = "https://github.com/earendil-works/gondolin";
    license = lib.licenses.asl20;
    mainProgram = "gondolin";
    platforms = lib.platforms.linux ++ lib.platforms.darwin;
  };
})
