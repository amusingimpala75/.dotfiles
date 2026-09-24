{
  deadnix,
  fd,
  nixf-diagnose,
  nixf,
  statix,

  lib,
  writeShellApplication,
  ...
}:
writeShellApplication {
  name = "linting";
  text = ''
    deadnix . || true
    fd --extension .nix --exec nixf-diagnose || true
    statix fix . -i .direnv || true
  '';
  meta = {
    description = "Lint the current directory with deadnix, statix, and nixf-diagnose";
    platforms = lib.platforms.all;
  };
  runtimeInputs = [
    deadnix
    fd
    nixf-diagnose
    nixf
    statix
  ];
}
