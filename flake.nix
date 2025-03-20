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
  };
  outputs =
    {
      self,
      nixpkgs,
      nixpkgs-stable-darwin,
      nixpkgs-stable-nixos,
      nix-darwin,
      home-manager,
      ...
    }@inputs:
    let
      lib = nixpkgs.lib;
      users = [
        "lukemurray"
        "murrayle23"
      ];
      darwinHosts = [
        "Lukes-Virtual-Machine"
        "Lukes-MacBook-Air"
      ];
      nixosHosts = [ "wsl-nix" ];
      userHostPairSeparator = "_";
      hosts = darwinHosts ++ nixosHosts;
      userHosts = builtins.foldl' (x: y: x ++ y) [ ] (
        lib.lists.forEach users (user: lib.lists.forEach hosts (host: user + userHostPairSeparator + host))
      );
      dotfilesDir = "~/.dotfiles";
      nixpkgsConfig = {
        config.allowUnfree = true;
        overlays = [
          inputs.alacritty-theme.overlays.default
          inputs.bible.overlays.default
          inputs.emacs-overlay.overlays.default
          inputs.nix-darwin-firefox.overlay
          inputs.nur.overlays.default
          inputs.sbarlua.overlay
          self.overlays.default # for my packages, whether that be script, customization, or vendoring

          (final: prev: { spicetify = inputs.spicetify.legacyPackages.${prev.system}; })

          (final: prev: lib.optionalAttrs prev.stdenv.isDarwin {
            # Override certain packages with
            # their binary equivalents on macOS.
            vlc = final.vlc-bin;
            firefox = final.firefox-bin;
            ghostty = final.ghostty-bin;

            # provide stable variants
            stable = nixpkgs-stable-darwin.legacyPackages.${prev.system};
          })

          (final: prev: lib.optionalAttrs prev.stdenv.isLinux {
            stable = nixpkgs-stable-nixos.legacyPackages.${prev.system};
          })
        ];
      };
      forAllSystems = lib.genAttrs [
        "aarch64-darwin"
        "x86_64-darwin"
        "aarch64-linux"
        "x86_64-linux"
        "i686-linux"
      ];
    in
    {
      darwinConfigurations = lib.genAttrs darwinHosts (
        system:
        let
          sys = import ./configurations/darwin/${system}/system.nix;
        in
        nix-darwin.lib.darwinSystem {
          system = sys.arch;
          specialArgs = inputs;
          modules = [
            { nixpkgs = nixpkgsConfig; }
            ./configurations/darwin/${system}
          ];
        }
      );
      nixosConfigurations = lib.genAttrs nixosHosts (
        system:
        let
          sys = import ./configurations/nixos/${system}/system.nix;
        in
        nixpkgs.lib.nixosSystem {
          system = sys.arch;
          specialArgs = { inherit inputs; };
          modules = [
            { nixpkgs = nixpkgsConfig; }
            ./configurations/nixos/${system}
            ./modules/nixos
          ];
        }
      );
      homeConfigurations = lib.genAttrs userHosts (
        userHost:
        let
          userHostPair = lib.strings.splitString userHostPairSeparator userHost;
          user = builtins.elemAt userHostPair 0;
          system = builtins.elemAt userHostPair 1;
          possible-darwin = ./configurations/darwin/${system}/system.nix;
          possible-nixos = ./configurations/nixos/${system}/system.nix;
          sys = import (if builtins.pathExists possible-darwin then possible-darwin else possible-nixos);
        in
        home-manager.lib.homeManagerConfiguration {
          pkgs = import nixpkgs (nixpkgsConfig // { system = sys.arch; });
          modules = [
            ./configurations/home/${user}
            ./modules/home
          ];
          extraSpecialArgs = {
            inherit inputs;
            username = user;
            dotfilesDir = dotfilesDir;
            hostname = system;
            userSettings = import ./configurations/home/${user}/settings.nix;
          };
        }
      );
      packages = forAllSystems (
        platform:
        let
          pkgs = import nixpkgs (nixpkgsConfig // { system = platform; });
        in
        {
          default = self.packages.${platform}.install;

          emacs = pkgs.my.emacs;
          install = pkgs.my.install;
          launcher = pkgs.my.launcher;
        }
      );
      apps = forAllSystems (platform: {
        default = self.apps.${platform}.install;

        emacs = {
          type = "app";
          program = "${self.packages.${platform}.emacs}/bin/emacs";
        };

        install = {
          type = "app";
          program = "${self.packages.${platform}.install}/bin/install";
        };

        launcher = {
          type = "app";
          program = "${self.packages.${platform}.launcher}/bin/launcher";
        };
      });
      overlays = {
        default = import ./overlays;
      };
    };
}
