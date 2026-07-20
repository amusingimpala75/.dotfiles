{
  inputs,
  self,
  ...
}:
{
  flake.modules.darwin.brew = {
    nixpkgs.overlays = [
      inputs.brew-nix.overlays.default
      self.overlays.brew-hashes
    ];
  };

  flake-file.inputs = {
    brew-api = {
      url = "github:BatteredBunny/brew-api";
      flake = false;
    };
    brew-nix = {
      url = "github:BatteredBunny/brew-nix";
      inputs = {
        brew-api.follows = "brew-api";
        nix-darwin.follows = "nix-darwin";
        nixpkgs.follows = "nixpkgs";
      };
    };
  };
}
