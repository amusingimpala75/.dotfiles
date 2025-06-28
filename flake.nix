{
  description = "My system configurations for macOS, WSL, and NixOS";

  inputs = {
    flake-parts.url = "github:hercules-ci/flake-parts";

    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nixpkgs-stable-darwin.url = "github:NixOS/nixpkgs/nixpkgs-25.05-darwin";
    nixpkgs-stable-nixos.url = "github:NixOS/nixpkgs/nixos-25.05";

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
    emacs-overlay.inputs.nixpkgs-stable.follows = "nixpkgs-stable-nixos";

    alacritty-theme.url = "github:alexghr/alacritty-theme.nix";
    alacritty-theme.inputs.nixpkgs.follows = "nixpkgs";
    alacritty-theme.inputs.flake-parts.follows = "flake-parts";

    textfox.url = "github:amusingimpala75/textfox/fix-nur"; # TODO back to adriankarlen when PR merged
    textfox.inputs.nixpkgs.follows = "nixpkgs";
    textfox.inputs.nur.follows = "nur";

    spicetify.url = "github:Gerg-L/spicetify-nix";
    spicetify.inputs.nixpkgs.follows = "nixpkgs";

    bible.url = "github:amusingimpala75/bible.sh";
    bible.inputs.nixpkgs.follows = "nixpkgs";
    bible.inputs.flake-parts.follows = "flake-parts";

    nix-wallpaper.url = "github:lunik1/nix-wallpaper";
    nix-wallpaper.inputs.nixpkgs.follows = "nixpkgs";

    devshell.url = "github:numtide/devshell";
    devshell.inputs.nixpkgs.follows = "nixpkgs";

    zen-browser-darwin.url = "github:wuz/nix-darwin-browsers";
    zen-browser-darwin.inputs.nixpkgs.follows = "nixpkgs";

    zen-browser-nixos.url = "github:marceColl/zen-browser-flake";
    zen-browser-nixos.inputs.nixpkgs.follows = "nixpkgs";


    nixvim.url = "github:nix-community/nixvim";
    nixvim.inputs.nixpkgs.follows = "nixpkgs";
    nixvim.inputs.flake-parts.follows = "flake-parts";
  };

  outputs = inputs@{ flake-parts, ... }:
  let
    dotfilesDir = "~/.dotfiles";
    root = ./.;
  in
  flake-parts.lib.mkFlake { inherit inputs; } ({ lib, self, withSystem, ...}: {
    imports = [
      inputs.home-manager.flakeModules.home-manager
      inputs.devshell.flakeModule
      inputs.nixvim.flakeModules.default
    ];
    flake = {
      darwinConfigurations = {
        Lukes-MacBook-Air = inputs.nix-darwin.lib.darwinSystem {
          system = "aarch64-darwin";
          specialArgs = { inherit inputs root self; }; # :TODO: maybe should just be = inputs;
          modules = [
            ./configurations/darwin/Lukes-MacBook-Air
            ./modules/darwin
          ];
        };
        Lukes-Virtual-Machine = inputs.nix-darwin.lib.darwinSystem {
          system = "aarch64-darwin";
          specialArgs = { inherit inputs root self; }; # :TODO: maybe should just be = inputs;
          modules = [
            ./configurations/darwin/Lukes-MacBook-Air
            ./modules/darwin
          ];
        };
      };

      nixosConfigurations = {
        wsl-nix = inputs.nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = { inherit inputs root self; };
          modules = [
            ./configurations/nixos/wsl-nix
            ./modules/nixos
          ];
        };
        glorfindel = inputs.nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = { inherit inputs root self; };
          modules = [
            ./configurations/nixos/glorfindel
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
            ./configurations/home/lukemurray
            ./modules/home
          ];
          extraSpecialArgs = { inherit dotfilesDir inputs root self; };
        });

        "lukemurray@glorfindel" = withSystem "x86_64-linux" ({ pkgs, ... }:
        inputs.home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          modules = [
            ./configurations/home/lukemurray
            ./modules/home
          ];
          extraSpecialArgs = { inherit dotfilesDir inputs root self; };
        });

        murrayle23 = withSystem "x86_64-linux" ({pkgs, ...}:
        inputs.home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          modules = [
            ./configurations/home/murrayle23
            ./modules/home
          ];
          extraSpecialArgs = { inherit dotfilesDir inputs root self; };
        });
      };

      # :TODO: broken?
      # nixvim = 
      #   packages.enable = true;
      #   checks.enable = true;
      # ;

      overlays = {
        default = import ./overlays;
      };

      templates = {
        c = {
          path = ./templates/c;
          description = "basic C flake with gcc and clang (for clangd)";
        };
        java = {
          path = ./templates/java;
          description = "basic java 17 flake with jdtls";
        };
        js = {
          path = ./templates/js;
          description = "basic JS flake with typescript-language-server";
        };
        python-basic = {
          path = ./templates/python-basic;
          description = "basic python flake for homeworks";
        };
        rust = {
          path = ./templates/rust;
          description = "basic rust flake with cargo, rust-analyzer, rustc, and rustfmt";
        };
        zig = {
          path = ./templates/zig;
          description = "basic zig flake with zls";
        };
      };
    };

    systems = lib.systems.flakeExposed;
    perSystem = { self', lib, pkgs, system, ...}: {
      _module.args.pkgs =
        let
          shared-nixpkgs-config = ((import modules/shared/nixpkgs.nix) {
            inherit inputs lib root self;
          }).config.nixpkgs;
        in import inputs.nixpkgs {
          inherit system;
          config = shared-nixpkgs-config.config;
          overlays = shared-nixpkgs-config.overlays;
        };

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
          nixvim = mkAppPackage "nvim";
        };

        packages = {
          default = self'.packages.install;

          emacs = pkgs.my.emacs;
          install = pkgs.my.install;
          launcher = pkgs.my.launcher;
          nvim = pkgs.my-nvim;
        };

        devshells.default = {
          motd = "";
          packages = with pkgs; [
            fennel
            fennel-ls
          ];
        };

        nixvimConfigurations.nixvim = inputs.nixvim.lib.evalNixvim {
          inherit system;
          modules = [ ./configurations/nixvim/nixvim ];
        };
    };
  });
}
