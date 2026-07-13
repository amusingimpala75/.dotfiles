let
  flake = builtins.getFlake ("path:" + (toString ../..));
  gen-platform-matrix =
    { system, runner }:
    map (package: {
      inherit package runner;
    }) (builtins.attrNames flake.packages.${system});
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
