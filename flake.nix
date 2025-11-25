{
  description = "My system configurations for macOS, WSL, and NixOS";

  inputs = {
    flake-parts.url = "github:hercules-ci/flake-parts";

    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nixpkgs-bleeding.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
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

    textfox.url = "github:adriankarlen/textfox";
    textfox.inputs.nixpkgs.follows = "nixpkgs";

    spicetify.url = "github:Gerg-L/spicetify-nix";
    spicetify.inputs.nixpkgs.follows = "nixpkgs";

    bible.url = "github:amusingimpala75/bible.sh";
    bible.inputs.nixpkgs.follows = "nixpkgs";
    bible.inputs.flake-parts.follows = "flake-parts";

    nix-wallpaper.url = "github:lunik1/nix-wallpaper";
    nix-wallpaper.inputs.nixpkgs.follows = "nixpkgs";

    zen-browser.url = "github:0xc000022070/zen-browser-flake";
    zen-browser.inputs.nixpkgs.follows = "nixpkgs";
    zen-browser.inputs.home-manager.follows = "home-manager";

    nixvim.url = "github:nix-community/nixvim";
    nixvim.inputs.nixpkgs.follows = "nixpkgs";
    nixvim.inputs.flake-parts.follows = "flake-parts";

    nix-index-database.url = "github:nix-community/nix-index-database";
    nix-index-database.inputs.nixpkgs.follows = "nixpkgs";

    sops-nix.url = "github:Mic92/sops-nix";
    sops-nix.inputs.nixpkgs.follows = "nixpkgs";

    # TODO: remove once PR is merged
    nixpkgs-darwin-xwidgets.url = "github:tani/nixpkgs/emacs-xwidgets-darwin";
  };

  outputs =
    inputs@{ flake-parts, ... }:
    let
      root = ./.;
    in
    flake-parts.lib.mkFlake { inherit inputs; } (
      {
        lib,
        self,
        ...
      }:
      {
        _module.args.root = root;
        imports = [
          inputs.home-manager.flakeModules.home-manager
          inputs.nixvim.flakeModules.default
          (import ./modules/flake/autowire.nix)
        ];
        flake = {
          overlays = {
            default = import ./overlays;
          };
        };

        autowire = {
          apps.enable = true;
          configurations = {
            darwin.enable = true;
            home.enable = true;
            nixos.enable = true;
            nixvim.enable = true;
          };
          templates.enable = true;
        };

        nixvim = {
          # We have to manually override with pname and description
          packages.enable = false;
          checks.enable = true;
        };

        systems = lib.systems.flakeExposed;
        perSystem =
          {
            self',
            lib,
            pkgs,
            system,
            ...
          }:
          {
            _module.args.pkgs =
              let
                shared-nixpkgs-config =
                  ((import modules/shared/nixpkgs.nix) {
                    inherit
                      inputs
                      lib
                      root
                      self
                      ;
                  }).config.nixpkgs;
              in
              import inputs.nixpkgs {
                inherit system;
                config = shared-nixpkgs-config.config;
                overlays = shared-nixpkgs-config.overlays;
              };

            packages = {
              default = self'.packages.install;

              emacs = pkgs.my.emacs;
              install = pkgs.my.install;
              launcher = pkgs.my.launcher;
              nixvim = pkgs.my-nvim;
            };

            devShells.default = pkgs.mkShell {
              packages = with pkgs; [
                nixd
                luaPackages.fennel
                fennel-ls
                nixfmt-tree
                sops
              ];
            };

            formatter = pkgs.nixfmt-tree;
          };
      }
    );
}
