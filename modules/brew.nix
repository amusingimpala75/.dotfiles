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

    overlays.brew-hashes =
      final: prev:
      let
        replace-hash =
          package: hash:
          package.overrideAttrs (old: {
            src = final.fetchurl {
              url = builtins.head old.src.urls;
              inherit hash;
            };
          });
      in
      {
        brewCasks = prev.brewCasks.overrideScope (
          _: bprev: {
            steam = replace-hash bprev.steam "sha256-4av7qqe+Pg9IoODUwxMjPgWGGx0mrzKDDdyDi+iPJpE=";
          }
        );
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
