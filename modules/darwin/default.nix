{ self, ... }:
{
  imports = with self.modules.darwin; with self.modules.generic; [
    nixpkgs
    nix
  ];
}
