{
  inputs,
  ...
}:
{
  imports = [ inputs.wrappers.flakeModules.wrappers ];

  flake-file.inputs.wrappers = {
    url = "github:nix-community/nix-wrapper-modules";
    inputs.nixpkgs.follows = "nixpkgs";
  };
}
