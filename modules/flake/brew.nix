{
  self,
  ...
}:
{
  flake.modules.homeManager.brew =
    {
      inputs,
      ...
    }:
    {
      nixpkgs.overlays = [
        inputs.brew-nix.overlays.default
        self.overlays.brew-hashes
      ];
    };
}
