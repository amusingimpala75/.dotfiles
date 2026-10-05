{
  lib,
  self,
  ...
}:
{
  flake.overlays = {
    by-name = final: prev: {
      local = prev.local.overrideScope (
        _: _:
        lib.packagesFromDirectoryRecursive {
          inherit (final) callPackage;
          directory = self + "/packages/by-name";
        }
      );
    };

    emacs-packages = final: prev: {
      emacsPackagesFor =
        emacs:
        ((prev.emacsPackagesFor emacs).overrideScope (
          efinal: _:
          lib.packagesFromDirectoryRecursive {
            inherit (efinal) callPackage;
            directory = "${self}/packages/emacs-packages";
          }
        ));
    };

    lib =
      final: prev:
      lib.packagesFromDirectoryRecursive {
        inherit (final) callPackage;
        directory = "${self}/packages/lib";
      };
  };
}
