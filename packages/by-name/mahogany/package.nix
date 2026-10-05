{
  fetchFromGitHub,
  lib,

  cairo,
  libdrm,
  libinput,
  libxkbcommon,
  makeWrapper,
  meson,
  ninja,
  pango,
  pkg-config,
  sbcl,
  wayland,
  wayland-protocols,
  wayland-scanner,
  wlroots_0_20,
}:

sbcl.buildASDFSystem {
  pname = "mahogany";
  version = "0-unstable-2026-09-27";

  src = fetchFromGitHub {
    owner = "stumpwm";
    repo = "mahogany";
    rev = "e1d310538f1f7e54e2734187bc297b2ac1ff7817";
    hash = "sha256-EgDAysOQxnSIdwoDsnYdQ9GivkYRNkLQW3X1czhrgbQ=";
    fetchSubmodules = true;
  };

  patches = [ ./remove-deps-build.patch ];

  lispLibs = with sbcl.pkgs; [
    adopt
    alexandria
    atomics
    bordeaux-threads
    cffi-grovel
    cl-ansi-text
    closer-mop
    float-features
    fset
    iterate
    terminfo
  ];

  nativeBuildInputs = [
    makeWrapper
    meson
    ninja
    pkg-config
    sbcl
    wayland-protocols
    wayland-scanner
  ];

  buildInputs = [
    cairo
    libdrm
    libinput
    libxkbcommon
    pango
    wayland
    wlroots_0_20
  ];

  preBuild = ''
    export LD_LIBRARY_PATH="${lib.makeLibraryPath [ libxkbcommon ]}:$LD_LIBRARY_PATH"
    # Error about dangling symlink otherwise
    rm guix.scm
    export HOME=$PWD/.home
    mkdir -p "$HOME"
  '';

  buildPhase = ''
    runHook preBuild

    make

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    install -Dm755 build/mahogany $out/bin/mahogany
    install -Dm755 build/heart/libheart.so $out/lib/libheart.so

    wrapProgram $out/bin/mahogany \
      --prefix LD_LIBRARY_PATH : "$out/lib:${
        lib.makeLibraryPath [
          libxkbcommon
          wlroots_0_20
        ]
      }"

    runHook postInstall
  '';

  env.CFLAGS = "-O2 -I${lib.getDev libdrm}/include/libdrm";

  meta = {
    description = "Wayland tiling window manager inspired by StumpWM";
    homepage = "https://github.com/stumpwm/mahogany";
    license = lib.licenses.gpl2Plus;
    platforms = lib.platforms.linux;
    mainProgram = "mahogany";
  };
}
