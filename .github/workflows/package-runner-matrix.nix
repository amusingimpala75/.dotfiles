let
  flake = builtins.getFlake ("path:" + (toString ../..));
  gen-platform-matrix =
    { system, runner }:
    let
      packages = flake.packages.${system};
      whitelisted = [
        "write-flake"
        "write-inputs"
        "write-lock"
      ];
      filtered = flake.inputs.nixpkgs.lib.filterAttrs (
        name: package:
        (builtins.elem package.name whitelisted) || (builtins.elem system package.meta.platforms)
      ) packages;
    in
    map (package: {
      inherit package runner;
    }) (builtins.attrNames filtered);
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
