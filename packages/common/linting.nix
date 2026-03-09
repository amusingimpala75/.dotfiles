{
  deadnix,
  fd,
  nixf-diagnose,
  nixf,
  rustPlatform,
  statix,

  fetchFromGitHub,
  writeShellApplication,
  ...
}:
writeShellApplication {
  name = "linting";
  text = ''
    deadnix .
    fd --extension .nix --exec nixf-diagnose || true
    statix check . -i .direnv || true
  '';
  meta = {
    description = "Lint the current directory with deadnix, statix, and nixf-diagnose";
  };
  runtimeInputs = [
    deadnix
    fd
    nixf-diagnose
    nixf
    (statix.overrideAttrs (_: rec {
      src = fetchFromGitHub {
        owner = "oppiliappan";
        repo = "statix";
        rev = "e9df54ce918457f151d2e71993edeca1a7af0132";
        hash = "sha256-duH6Il124g+CdYX+HCqOGnpJxyxOCgWYcrcK0CBnA2M=";
      };
      cargoDeps = rustPlatform.fetchCargoVendor {
        inherit src;
        hash = "sha256-IeVGsrTXqmXbKRbJlBDv02fJ+rPRjwuF354/jZKRK/M=";
      };
    }))
  ];
}
