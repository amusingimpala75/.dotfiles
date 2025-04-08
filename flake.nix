{
  description = "My system configurations for macOS, WSL, and NixOS";

  inputs = {
    flake-parts.url = "github:hercules-ci/flake-parts";

    nixpkgs.url = "nixpkgs/nixpkgs-unstable";
    nixpkgs-stable-darwin.url = "nixpkgs/nixpkgs-24.11-darwin";
    nixpkgs-stable-nixos.url = "nixpkgs/nixos-24.11";

    nur.url = "github:nix-community/NUR";
    nur.inputs.nixpkgs.follows = "nixpkgs";
    nur.inputs.flake-parts.follows = "flake-parts";

    nixos-wsl.url = "github:nix-community/NixOS-WSL/main";
    nixos-wsl.inputs.nixpkgs.follows = "nixpkgs";

    nix-darwin.url = "github:LnL7/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    emacs-overlay.url = "github:nix-community/emacs-overlay";
    emacs-overlay.inputs.nixpkgs.follows = "nixpkgs";

    alacritty-theme.url = "github:alexghr/alacritty-theme.nix";
    alacritty-theme.inputs.nixpkgs.follows = "nixpkgs";
    alacritty-theme.inputs.flake-parts.follows = "flake-parts";

    nix-darwin-firefox.url = "github:bandithedoge/nixpkgs-firefox-darwin";
    nix-darwin-firefox.inputs.nixpkgs.follows = "nixpkgs";

    textfox.url = "github:amusingimpala75/textfox/fix-nur"; # TODO back to adriankarlen when PR merged
    textfox.inputs.nixpkgs.follows = "nixpkgs";
    textfox.inputs.nur.follows = "nur";

    sbarlua.url = "github:Lalit64/SbarLua/nix-darwin-package"; # Change to upstream once PR is merged
    sbarlua.inputs.nixpkgs.follows = "nixpkgs";

    spicetify.url = "github:Gerg-L/spicetify-nix";
    spicetify.inputs.nixpkgs.follows = "nixpkgs";

    bible.url = "github:amusingimpala75/bible.sh";
    bible.inputs.nixpkgs.follows = "nixpkgs";
    bible.inputs.flake-parts.follows = "flake-parts";

    nix-wallpaper.url = "github:lunik1/nix-wallpaper";
    nix-wallpaper.inputs.nixpkgs.follows = "nixpkgs";

    nix-rosetta-builder.url = "github:cpick/nix-rosetta-builder";
    nix-rosetta-builder.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs@{ flake-parts, ... }:
  let
    lib = inputs.nixpkgs.lib;
    dotfilesDir = "~/.dotfiles";
    nixpkgsConfig = { allowUnfree = true; };
    nixpkgsOverlays = [
      inputs.alacritty-theme.overlays.default
      inputs.bible.overlays.default
      inputs.emacs-overlay.overlays.default
      inputs.nix-darwin-firefox.overlay
      inputs.nur.overlays.default
      inputs.sbarlua.overlay
      inputs.self.overlays.default # for my packages, whether that be script, customization, or vendoring

      (final: prev: { nix-wallpaper = inputs.nix-wallpaper.packages.${prev.system}.default; })
      (final: prev: { spicetify = inputs.spicetify.legacyPackages.${prev.system}; })

      (final: prev: lib.optionalAttrs prev.stdenv.isDarwin {
        # Override certain packages with
        # their binary equivalents on macOS.
        vlc = final.vlc-bin;
        firefox = final.firefox-bin;
        ghostty = final.ghostty-bin;

        # provide stable variants
        stable = inputs.nixpkgs-stable-darwin.legacyPackages.${prev.system};
      })

      (final: prev: lib.optionalAttrs prev.stdenv.isLinux {
        stable = inputs.nixpkgs-stable-nixos.legacyPackages.${prev.system};
      })
    ];
  in
  flake-parts.lib.mkFlake { inherit inputs; } ({ lib, withSystem, ...}: {
    imports = [
      inputs.home-manager.flakeModules.home-manager
    ];
    flake = {
      darwinConfigurations = {
        Lukes-MacBook-Air = inputs.nix-darwin.lib.darwinSystem {
          system = "aarch64-darwin";
          specialArgs = { inherit inputs; }; # :TODO: maybe should just be = inputs;
          modules = [
            { nixpkgs.config = nixpkgsConfig; nixpkgs.overlays = nixpkgsOverlays; }
            ./configurations/darwin/Lukes-MacBook-Air
          ];
        };
        Lukes-Virtual-Machine = inputs.nix-darwin.lib.darwinSystem {
          system = "aarch64-darwin";
          specialArgs = { inherit inputs; }; # :TODO: maybe should just be = inputs;
          modules = [
            { nixpkgs.config = nixpkgsConfig; nixpkgs.overlays = nixpkgsOverlays; }
            ./configurations/darwin/Lukes-MacBook-Air
          ];
        };
      };

      nixosConfigurations = {
        wsl-nix = inputs.nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = { inherit inputs; };
          modules = [
            { nixpkgs.config = nixpkgsConfig; }
            ./configurations/nixos/wsl-nix
            ./modules/nixos
          ];
        };
      };

      # :TODO: genericize pkgs calls
      homeConfigurations = {
        lukemurray = withSystem "aarch64-darwin" ({ pkgs, ... }:
        inputs.home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          modules = [
            { nixpkgs.config = nixpkgsConfig; nixpkgs.overlays = nixpkgsOverlays; }
            ./configurations/home/lukemurray
            ./modules/home
          ];
          extraSpecialArgs = {
            inherit inputs;
            dotfilesDir = dotfilesDir;
          };
        });

        murrayle23 = withSystem "x86_64-linux" ({pkgs, ...}:
        inputs.home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          modules = [
            { nixpkgs.config = nixpkgsConfig; nixpkgs.overlays = nixpkgsOverlays; }
            ./configurations/home/murrayle23
            ./modules/home
          ];
          extraSpecialArgs = {
            inherit inputs;
            dotfilesDir = dotfilesDir;
          };
        });
      };

      overlays = {
        default = import ./overlays;
      };

      templates = {
        python-basic = {
          path = ./templates/python-basic;
          description = "basic python flake for homeworks";
        };
      };
    };

    systems = lib.systems.flakeExposed;
    perSystem = { self', pkgs, system, ...}: {
      _module.args.pkgs = import inputs.nixpkgs ({
        inherit system;
        config = nixpkgsConfig;
        overlays = nixpkgsOverlays;
      });

      apps = let
        mkAppPackage = name: {
          type = "app";
          program = "${self'.packages.${name}}/bin/${name}";
        };
      in {
        default = self'.apps.install;

        emacs = mkAppPackage "emacs";
        install = mkAppPackage "install";
        launcher = mkAppPackage "launcher";
      };

      packages = {
        default = self'.packages.install;

        emacs = pkgs.my.emacs;
        install = pkgs.my.install;
        launcher = pkgs.my.launcher;
      };
    };
  });
}
