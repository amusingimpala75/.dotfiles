{
  output ? ".cache/gondolin/nix-assets",

  coreutils,
  e2fsprogs,
  gondolin,
  lib,
  lz4,
  nix,
  python3,
  writeShellApplication,
}:
writeShellApplication {
  name = "gondolin-build-nix-image";

  runtimeInputs = [
    coreutils
    e2fsprogs
    gondolin
    lz4
    nix
    python3
  ];

  text = builtins.replaceStrings [ "@output@" ] [ output ] (builtins.readFile ./gondolin-build-nix-image.sh);

  passthru = { inherit output; };

  meta = {
    description = "Build a globally cached Gondolin image from a flake development shell";
    platforms = lib.platforms.all;
  };
}
