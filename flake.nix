{
  description = "My system configurations for macOS, WSL, and NixOS";

  inputs = {
    flake-parts.url = "github:hercules-ci/flake-parts";

    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nixpkgs-bleeding.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nixpkgs-stable-darwin.url = "github:NixOS/nixpkgs/nixpkgs-25.11-darwin";
    nixpkgs-stable-nixos.url = "github:NixOS/nixpkgs/nixos-25.11";

    nur.url = "github:nix-community/NUR";
    nur.inputs.nixpkgs.follows = "nixpkgs";

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

    textfox.url = "github:adriankarlen/textfox";
    textfox.inputs.nixpkgs.follows = "nixpkgs";

    spicetify.url = "github:Gerg-L/spicetify-nix";
    spicetify.inputs.nixpkgs.follows = "nixpkgs";

    bible.url = "github:amusingimpala75/bible.sh";
    bible.inputs.nixpkgs.follows = "nixpkgs";

    nix-wallpaper.url = "github:lunik1/nix-wallpaper";
    nix-wallpaper.inputs.nixpkgs.follows = "nixpkgs";

    zen-browser.url = "github:0xc000022070/zen-browser-flake";
    zen-browser.inputs.nixpkgs.follows = "nixpkgs";
    zen-browser.inputs.home-manager.follows = "home-manager";

    nixvim.url = "github:nix-community/nixvim";
    nixvim.inputs.nixpkgs.follows = "nixpkgs";

    nix-index-database.url = "github:nix-community/nix-index-database";
    nix-index-database.inputs.nixpkgs.follows = "nixpkgs";

    sops-nix.url = "github:Mic92/sops-nix";
    sops-nix.inputs.nixpkgs.follows = "nixpkgs";

    direnv-instant.url = "github:Mic92/direnv-instant";
    direnv-instant.inputs.nixpkgs.follows = "nixpkgs";

    opencode-ralph.url = "github:rot13maxi/opencode-ralph";
    opencode-ralph.flake = false;

    # TODO not necessary after pi in nixpkgs
    llm-agents.url = "github:numtide/llm-agents.nix";
    llm-agents.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    inputs@{ flake-parts, ... }:
    let
      flakeModules = {
        autowire = import ./modules/flake/autowire.nix;
        modules = import ./modules/flake/modules.nix;
        nix = import ./modules/flake/nix.nix;
        nixpkgs = import ./modules/flake/nixpkgs.nix;
        nixvim = import ./modules/flake/nixvim.nix;
        pi = import ./modules/flake/pi.nix;
      };
    in
    flake-parts.lib.mkFlake { inherit inputs; } (
      {
        lib,
        ...
      }:
      {
        _module.args.root = ./.;
        imports = [
          inputs.flake-parts.flakeModules.modules
          inputs.nix-darwin.flakeModules.default
          inputs.home-manager.flakeModules.home-manager
          inputs.nixvim.flakeModules.default
        ]
        ++ (builtins.attrValues flakeModules);

        flake = {
          inherit flakeModules;
        };

        autowire = {
          apps.enable = true;
          configurations = {
            darwin.enable = true;
            home.enable = true;
            nixos.enable = true;
            nixvim.enable = true;
          };
          overlays.enable = true;
          templates.enable = true;
        };

        systems = lib.systems.flakeExposed;
        perSystem =
          {
            self',
            pkgs,
            ...
          }:
          {
            packages = {
              default = self'.packages.install;

              emacs = pkgs.my.emacs;
              install = pkgs.my.install;
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
