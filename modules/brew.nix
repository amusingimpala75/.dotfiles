{
  inputs,
  self,
  ...
}:
{
  flake = {
    modules.darwin.brew = {
      nixpkgs.overlays = [
        inputs.brew-nix.overlays.default
        self.overlays.brew-hashes
      ];
    };

    overlays.brew-hashes = _: prev: {
      brewCasks = prev.brewCasks // {
        steam = prev.brewCasks.steam.overrideAttrs (_: {
          # Valve's ZIP contains a tarball rather than Steam.app directly.
          unpackPhase = ''
            runHook preUnpack
            unzip -q "$src"
            tar -xzf SteamMacBootstrapper.tar.gz --exclude='._*'
            runHook postUnpack
          '';
        });
      };
    };
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
