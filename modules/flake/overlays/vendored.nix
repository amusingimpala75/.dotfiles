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
  flake.overlays = {
    common = platformPackages "common";
    darwin = platformPackages "darwin";
    linux = platformPackages "linux";

    emacs-packages = final: prev: {
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

    lib =
      final: prev:
      prev.lib.packagesFromDirectoryRecursive {
        inherit (final) callPackage;
        directory = "${self}/packages/lib";
      };
  };
}
