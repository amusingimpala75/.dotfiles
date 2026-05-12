{
  self,
  ...
}:
let
  platformPackages = platform: final: prev: {
    local = prev.local.overrideScope (
      _: _:
      prev.lib.packagesFromDirectoryRecursive {
        inherit (final) callPackage;
        directory = "${self}/packages/${platform}";
      }
    );
  };
in
{
  flake.overlays.common = platformPackages "common";
  flake.overlays.darwin = platformPackages "darwin";
  flake.overlays.linux = platformPackages "linux";

  flake.overlays.emacs-packages = final: prev: {
    emacsPackagesFor =
      emacs:
      ((prev.emacsPackagesFor emacs).overrideScope (
        efinal: _:
        final.lib.packagesFromDirectoryRecursive {
          inherit (efinal) callPackage;
          directory = "${self}/packages/emacs-packages";
        }
      ));
  };

  flake.overlays.lib =
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
        directory = "${self}/packages/lib";
      }
    else
      { };
}
