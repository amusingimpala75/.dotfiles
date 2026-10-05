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

    emacs-packages = _: prev: {
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
      final: _:
      lib.packagesFromDirectoryRecursive {
        inherit (final) callPackage;
        directory = "${self}/packages/lib";
      };
  };
}
