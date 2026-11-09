{
  flakeRef,
  successfulBuilds ? "[]",
}:
let
  flake = builtins.getFlake flakeRef;
  ciPackages = import (flake.outPath + "/.github/workflows/package-builds.nix") { inherit flake; };
  records = builtins.fromJSON successfulBuilds;
  gen-platform-matrix =
    { system, runner }:
    let
      packages = ciPackages.${system};
      whitelisted = [
        "write-flake"
        "write-inputs"
        "write-lock"
      ];
      filtered = flake.inputs.nixpkgs.lib.filterAttrs (
        name: package:
        (builtins.elem name whitelisted)
        || builtins.addErrorContext "while checking ${name} for ${system}" (
          builtins.elem system package.meta.platforms
        )
      ) packages;
    in
    builtins.filter (build: !(builtins.elem build.cacheKey records)) (
      map (
        package:
        let
          drvPath = filtered.${package}.drvPath;
        in
        {
          inherit
            package
            runner
            system
            drvPath
            ;
          cacheKey = "package-build-success-v2-${system}-${package}-${baseNameOf drvPath}";
        }
      ) (builtins.attrNames filtered)
    );
in
flake.inputs.nixpkgs.lib.flatten (
  map gen-platform-matrix [
    {
      system = "aarch64-darwin";
      runner = "macos-latest";
    }
    {
      system = "x86_64-linux";
      runner = "ubuntu-latest";
    }
  ]
)
