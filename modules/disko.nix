{
  inputs,
  ...
}:
{
  flake.modules.nixos.disko = {
    imports = [ inputs.disko.nixosModules.default ];
  };

  flake-file.inputs.disko = {
    url = "github:nix-community/disko";
    inputs.nixpkgs.follows = "nixpkgs";
  };
}
