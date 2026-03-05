final: prev:
# This is stupid. I only have this because Determinate nix's
# schema check is unintelligent and runs with NO nixpkgs,
# so prev.lib doesn't exist. Whoever decided that was a
# sane default is not very smart. For instance, that should
# (in theory) prevent be from even saying prev.callPackage,
# which is something literally every overlay should have.
if (prev ? lib) then
  prev.lib.packagesFromDirectoryRecursive {
    inherit (final) callPackage;
    directory = ../packages/lib;
  }
else
  { }
