{
  lib,
  stdenv,
  buildGoModule,
  fetchFromGitHub,
  pkg-config,
  alsa-lib,
  libGL,
  libx11,
  libxcursor,
  libxi,
  libxinerama,
  libxrandr,
  libxxf86vm,
}:

buildGoModule (finalAttrs: {
  pname = "neko";
  version = "0.1.43";

  src = fetchFromGitHub {
    owner = "crgimenes";
    repo = "neko";
    tag = "v${finalAttrs.version}";
    hash = "sha256-2XlY0myW61HGfKaNVhIw1Yg71hhgc1gxqzdNudk2dR0=";
  };

  vendorHash = "sha256-pir3S6JkMDKteAGlsk20TN+LPh8ZqLaVFxydbX5q9i4=";

  __structuredAttrs = true;
  strictDeps = true;

  env.CGO_ENABLED = if stdenv.hostPlatform.isLinux then "1" else "0";

  nativeBuildInputs = lib.optionals stdenv.hostPlatform.isLinux [
    pkg-config
  ];

  buildInputs = lib.optionals stdenv.hostPlatform.isLinux [
    alsa-lib
    libGL
    libx11
    libxcursor
    libxi
    libxinerama
    libxrandr
    libxxf86vm
  ];

  ldflags = [
    "-s"
    "-w"
  ];

  skins =
    let
      root =
        (fetchFromGitHub {
          owner = "onekocord";
          repo = "onekocord";
          rev = "d34b0292ac69b51504fd3f83b2df41095f0da37e";
          hash = "sha256-fjDVFIAQOIywS5A/gGqe3v5ifpkCs0/ScmvhHR7+vSw=";
        })
        |> (root: root + "/skins");
    in
    (builtins.readDir root)
    |> (
      files:
      lib.mapAttrs' (name: _: {
        name = lib.removeSuffix ".png" name;
        value = "${root}/${name}";
      }) files
    );

  meta = {
    description = "Cross-platform cursor-chasing cat reimplementation written in Go";
    homepage = "https://github.com/crgimenes/neko";
    license = lib.licenses.bsd2;
    mainProgram = "neko";
  };
})
