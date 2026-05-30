# DO-NOT-EDIT. This file was auto-generated using github:vic/flake-file.
# Use `nix run .#write-flake` to regenerate it.
{
  description = "My system configurations for macOS, WSL, and NixOS";

  outputs =
    inputs:
    inputs.flake-parts.lib.mkFlake { inherit inputs; } (
      {
        lib,
        ...
      }:
      {
        # Custom import-tree courtesy of iampavel.dev
        imports = lib.fileset.toList (
          lib.fileset.fileFilter (file: file.hasExt "nix" && !(lib.hasPrefix "_" file.name)) ./modules/flake
        );
      }
    );

  inputs = {
    agent-sandbox = {
      url = "github:archie-judd/agent-sandbox.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    angrr = {
      url = "github:linyinfeng/angrr";
      inputs = {
        nix-darwin.follows = "nix-darwin";
        nixpkgs.follows = "nixpkgs";
      };
    };
    automader = {
      url = "github:amusingimpala75/automata_grader";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    bible = {
      url = "github:amusingimpala75/bible.sh";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    breaktime = {
      url = "github:amusingimpala75/breaktime";
      inputs.nixpkgs.follows = "nixpkgs";
    };
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
    ccusage = {
      url = "github:ryoppippi/ccusage";
      inputs = {
        agent-skills.follows = "";
        nixpkgs.follows = "nixpkgs";
      };
    };
    determinate-nix-cli.url = "github:DeterminateSystems/nix-src";
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    emacs-overlay = {
      url = "github:nix-community/emacs-overlay";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        nixpkgs-stable.follows = "nixpkgs-stable-nixos";
      };
    };
    flake-file.url = "github:denful/flake-file";
    flake-parts.url = "github:hercules-ci/flake-parts";
    hister = {
      url = "github:asciimoo/hister";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    impermanence = {
      url = "github:nix-community/impermanence";
      inputs = {
        home-manager.follows = "home-manager";
        nixpkgs.follows = "nixpkgs";
      };
    };
    jj-spr = {
      url = "github:amusingimpala75/jj-spr/fix-nix-jj-38";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-anywhere = {
      url = "github:nix-community/nixos-anywhere";
      inputs = {
        disko.follows = "";
        nix-vm-test.follows = "";
        nixos-images.follows = "";
        nixos-stable.follows = "";
        nixpkgs.follows = "nixpkgs";
        treefmt-nix.follows = "";
      };
    };
    nixos-wsl = {
      url = "github:nix-community/NixOS-WSL/main";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nixpkgs-bleeding.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nixpkgs-stable-darwin.url = "github:NixOS/nixpkgs/nixpkgs-26.05-darwin";
    nixpkgs-stable-nixos.url = "github:NixOS/nixpkgs/nixos-26.05";
    nur = {
      url = "github:nix-community/NUR";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    pi-quota-usage = {
      url = "github:Limb/pi-quota-usage";
      flake = false;
    };
    qylock = {
      url = "github:LordHerdier/qylock-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
}
