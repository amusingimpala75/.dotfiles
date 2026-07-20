{
  inputs,
  ...
}:
{
  flake.modules.nixos.impermanence = {
    imports = [ inputs.impermanence.nixosModules.default ];
  };

  flake-file.inputs.impermanence = {
    url = "github:nix-community/impermanence";
    inputs = {
      nixpkgs.follows = "nixpkgs";
      home-manager.follows = "home-manager";
    };
  };
}
