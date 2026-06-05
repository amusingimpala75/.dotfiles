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
    prev.lib.packagesFromDirectoryRecursive {
      inherit (final) callPackage;
      directory = "${self}/packages/lib";
    };
}
