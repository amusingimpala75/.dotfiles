# AI generated, but at least for now it compiles and runs correctly
{
  fetchFromGitHub,
  lib,
  stdenv,
  meson,
  ninja,
  pkg-config,
  makeWrapper,
  sbcl,
  wlroots_0_19,
  wayland,
  wayland-scanner,
  wayland-protocols,
  libxkbcommon,
  libxcb,
  cairo,
  pango,
  libdrm
}:

let
  sbclEnv = sbcl.withPackages (ps: with ps; [
    alexandria
    cl-ansi-text
    cl-colors2
    terminfo
    adopt
    iterate
    atomics
    fset
    bordeaux-threads
    cffi
    cffi-grovel
    closer-mop
    fiasco
  ]);

in
stdenv.mkDerivation {
  pname = "mahogany";
  version = "unstable-2026-03-19";

  src = fetchFromGitHub {
    owner = "stumpwm";
    repo = "mahogany";
    rev = "d18e1042a50a72211a5310555741b22a12c868b2";
    hash = "sha256-8kbclq1hwU2VL1alPI8tNByuszDJU3sPuvn4cW5MpvE=";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
    makeWrapper
    wayland
    wayland-scanner
    sbclEnv
  ];

  buildInputs = [
    wlroots_0_19
    wayland
    wayland-protocols
    libxkbcommon
    libxcb
    cairo
    pango
    libdrm
  ];

  dontConfigure = true;
  hardeningDisable = [ "fortify" ];
  dontStrip = true;
  CFLAGS = "-I${lib.getDev libdrm}/include/libdrm";
  C_INCLUDE_PATH = "${lib.getDev libdrm}/include/libdrm";

  buildPhase = ''
    runHook preBuild

    export LD_LIBRARY_PATH="${lib.makeLibraryPath [ wayland libxkbcommon wlroots_0_19 cairo pango ]}:$LD_LIBRARY_PATH"

    make LISP=sbcl
    runHook postBuild
  '';

  checkPhase = ''
    runHook preCheck
    export LD_LIBRARY_PATH="${lib.makeLibraryPath [ wayland libxkbcommon wlroots_0_19 cairo pango ]}:$LD_LIBRARY_PATH"
    make LISP=sbcl test
    runHook postCheck
  '';

  installPhase = ''
    runHook preInstall

    install -Dm755 build/mahogany $out/bin/mahogany
    install -Dm755 build/lib/libheart.so $out/lib/libheart.so

    wrapProgram $out/bin/mahogany \
      --set SBCL_HOME "${sbcl}/lib/sbcl" \
      --prefix LD_LIBRARY_PATH : "$out/lib:${lib.makeLibraryPath [
        wlroots_0_19
        libxkbcommon
        wayland
        cairo
        pango
      ]}"

    runHook postInstall
  '';

  doCheck = true;

  meta = {
    description = "Wayland tiling window manager inspired by StumpWM";
    homepage = "https://github.com/stumpwm/mahogany";
    license = lib.licenses.gpl2Plus;
    platforms = lib.platforms.linux;
    mainProgram = "mahogany";
  };
}
