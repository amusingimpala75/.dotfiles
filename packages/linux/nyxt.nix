# AI generated, but it compiles and runs.
# [TODO] support macOS, and controlling
# backend if you really want webkit
{
  lib,
  stdenv,
  buildNpmPackage,
  sbcl_2_4_6,
  gnumake,
  pkg-config,
  makeWrapper,
  nodejs_22,
  electron,
  bash,
  python312,
  libfixposix,
  openssl,
  sqlite,
  xdg-utils,
  xclip,
  wl-clipboard,
  enchant,
  fetchFromGitHub,
}:
let
  src = fetchFromGitHub {
    owner = "atlas-engineer";
    repo = "nyxt";
    rev = "aeb6c72cf1ef4216d4bd6437b4e21ceac18b17e7";
    hash = "sha256-tkeRoDAzZCg4LHpHklrAKrMMjj9OfChEYfa25mPwwfU=";
    fetchSubmodules = true;
  };

  pname = "nyxt";
  version = "4.x";
  pythonForNodeGyp = python312.withPackages (ps: [ ps.setuptools ]);

  clElectronNodeModules = buildNpmPackage {
    nodejs = nodejs_22;
    pname = "cl-electron-node-modules";
    version = "0.0.1";
    src = "${src}/_build/cl-electron";
    npmDepsHash = "sha256-dHuhSAXgWP1wa71kq7P2wVVEEPYm5lsn1h+PRWCGDnQ=";
    npmInstallFlags = [ "--omit=dev" ];
    npmRebuildFlags = [ "synchronous-socket" ];
    dontNpmBuild = true;
    postPatch = ''
      substituteInPlace package.json \
        --replace '"postinstall":' '"postinstall-disabled":'
    '';
    installPhase = ''
      runHook preInstall
      mkdir -p $out
      cp -r node_modules $out/node_modules
      runHook postInstall
    '';
  };
in
stdenv.mkDerivation {
  inherit pname version src;
  nativeBuildInputs = [
    sbcl_2_4_6
    gnumake
    pkg-config
    makeWrapper
    nodejs_22
    pythonForNodeGyp
  ];

  buildInputs = [
    libfixposix
    openssl
    sqlite
    enchant
  ];

  env.LD_LIBRARY_PATH = lib.makeLibraryPath [
    libfixposix
    openssl
    sqlite
    enchant
  ];

  buildPhase = ''
    runHook preBuild

    export HOME="$TMPDIR"
    export CL_SOURCE_REGISTRY="$PWD/_build//"
    export ASDF_OUTPUT_TRANSLATIONS="$PWD:$PWD"
    export NYXT_VERSION="${version}"

    cp -r ${clElectronNodeModules}/node_modules "$PWD/_build/cl-electron/"
    chmod -R u+w "$PWD/_build/cl-electron/node_modules"

    (cd "$PWD/_build/cl-electron" && \
      export PYTHON='${pythonForNodeGyp}/bin/python3' && \
      export npm_config_python='${pythonForNodeGyp}/bin/python3' && \
      export npm_config_nodedir='${electron.headers}' && \
      npm rebuild synchronous-socket --offline)

    make all \
      NYXT_SUBMODULES=true \
      NYXT_RENDERER=electron \
      NODE_SETUP=false

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p "$out/bin" "$out/share/nyxt"

    install -Dm755 nyxt "$out/bin/nyxt"

    cp -r \
      _build \
      assets \
      libraries \
      licenses \
      source \
      tests \
      nyxt.asd \
      README.org \
      makefile \
      INSTALL \
      developer-manual.org \
      "$out/share/nyxt/"

    cat > "$out/bin/cl-electron-server" <<'EOF'
#!${bash}/bin/bash
set -euo pipefail

opts=()
while [[ "$#" -gt 0 ]]; do
  case "$1" in
    --*)
      opts+=("$1")
      shift
      ;;
    *)
      break
      ;;
  esac
done

# Drop the server-path argument passed by cl-electron and replace it with
# our packaged server.js path.
if [[ "$#" -gt 0 ]]; then
  shift
fi

exec ${electron}/bin/electron "''${opts[@]}" "$APPDIR/source/server.js" "$@"
EOF
    chmod +x "$out/bin/cl-electron-server"

    wrapProgram "$out/bin/nyxt" \
      --set-default APPDIR "$out/share/nyxt/_build/cl-electron" \
      --set-default CL_SOURCE_REGISTRY "$out/share/nyxt/_build//" \
      --set-default NYXT_SUBMODULES true \
      --set-default NODE_SETUP false \
      --set-default NYXT_RENDERER electron \
      --prefix PATH : "$out/bin:${lib.makeBinPath [ xdg-utils xclip wl-clipboard nodejs_22 ]}" \
      --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath [ libfixposix openssl sqlite enchant ]}"

    runHook postInstall
  '';

  dontStrip = true;

  meta = {
    description = "Infinitely extensible keyboard-oriented web browser (Nyxt 4 with Electron renderer)";
    homepage = "https://nyxt-browser.com";
    license = lib.licenses.bsd3;
    mainProgram = "nyxt";
    platforms = lib.platforms.linux;
  };
}
