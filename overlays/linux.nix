final: prev: {
  local = prev.local.overrideScope (
    _: _:
    prev.lib.packagesFromDirectoryRecursive {
      inherit (final) callPackage;
      directory = ../packages/linux;
    }
  );
}
