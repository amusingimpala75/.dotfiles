{
  inputs,
  ...
}:
{
  imports = [ inputs.wrappers.flakeModules.wrappers ];

  flake-file.inputs.wrappers = {
    url = "github:BirdeeHub/nix-wrapper-modules";
    inputs.nixpkgs.follows = "nixpkgs";
  };
}
