{
  inputs,
  self,
  ...
}:
{
  flake.lib.mkNixos = system: hostname: mainModule: {
    "${hostname}" = inputs.nixpkgs.lib.nixosSystem {
      inherit system;
      modules =
        with self.modules.generic;
        with self.modules.nixos;
        [
          { networking.hostName = hostname; }
          mainModule
          nixpkgs
          nix
        ];
    };
  };

  flake.lib.mkDarwin = system: hostname: mainModule: {
    "${hostname}" = inputs.nix-darwin.lib.darwinSystem {
      inherit system;
      modules =
        with self.modules.generic;
        with self.modules.darwin;
        [
          { networking.hostName = hostname; }
          mainModule
          nixpkgs
          nix
        ];
    };
  };
}
