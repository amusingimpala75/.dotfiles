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

  flake.lib.mkHome = system: username: mainModule: {
    "${username}" = inputs.home-manager.lib.homeManagerConfiguration {
      pkgs = import inputs.nixpkgs { inherit system; };
      modules =
        with self.modules.homeManager;
        with self.modules.generic;
        [
          ../home
          nixpkgs
          nix
          sops
          mainModule
          (
            {
              config,
              pkgs,
              ...
            }:
            {
              home = {
                inherit username;
                homeDirectory = if pkgs.stdenv.isDarwin then "/Users/${username}" else "/home/${username}";
              };
              news.display = "silent";
              programs.home-manager.enable = true;
              systemd.user.sessionVariables = config.home.sessionVariables;
            }
          )
        ];
      extraSpecialArgs = { inherit inputs; };
    };
  };
}
