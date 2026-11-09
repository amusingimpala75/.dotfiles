{
  flakeRef,
  system,
  package,
}:
let
  flake = builtins.getFlake flakeRef;
  packages = import (flake.outPath + "/.github/workflows/package-builds.nix") { inherit flake; };
in
packages.${system}.${package}
