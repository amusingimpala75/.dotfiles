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

    emacs-overlay = {
      url = "github:nix-community/emacs-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.nixpkgs-stable.follows = "nixpkgs-stable-nixos";
    };

    alacritty-theme.url = "github:alexghr/alacritty-theme.nix";
    alacritty-theme.inputs.nixpkgs.follows = "nixpkgs";

    textfox.url = "github:adriankarlen/textfox";
    textfox.inputs.nixpkgs.follows = "nixpkgs";

    bible.url = "github:amusingimpala75/bible.sh";
    bible.inputs.nixpkgs.follows = "nixpkgs";

    nix-wallpaper.url = "github:lunik1/nix-wallpaper";
    nix-wallpaper.inputs.nixpkgs.follows = "nixpkgs";

    nix-index-database.url = "github:nix-community/nix-index-database";
    nix-index-database.inputs.nixpkgs.follows = "nixpkgs";

    sops-nix.url = "github:Mic92/sops-nix";
    sops-nix.inputs.nixpkgs.follows = "nixpkgs";

    brew-api.url = "github:BatteredBunny/brew-api";
    brew-api.flake = false;
    brew-nix.url = "github:BatteredBunny/brew-nix";
    brew-nix.inputs = {
      brew-api.follows = "brew-api";
      nix-darwin.follows = "nix-darwin";
      nixpkgs.follows = "nixpkgs";
    };

    jj-spr.url = "github:amusingimpala75/jj-spr/fix-nix-jj-38";
    jj-spr.inputs.nixpkgs.follows = "nixpkgs";

    pi-extensions.url = "github:badlogic/pi-mono?shallow=1&dir=packages/coding-agent/examples/extensions";
    pi-extensions.flake = false;
    pi-quota-usage.url = "github:Limb/pi-quota-usage";
    pi-quota-usage.flake = false;

    import-tree.url = "github:vic/import-tree";

    automader.url = "github:amusingimpala75/automata_grader";
    automader.inputs.nixpkgs.follows = "nixpkgs";

    determinate-nix-cli.url = "github:DeterminateSystems/nix-src";

    agent-sandbox.url = "github:archie-judd/agent-sandbox.nix";
    agent-sandbox.inputs.nixpkgs.follows = "nixpkgs";

    angrr.url = "github:linyinfeng/angrr";
    angrr.inputs = {
      nixpkgs.follows = "nixpkgs";
      nix-darwin.follows = "nix-darwin";
    };
  };

  outputs =
    inputs: inputs.flake-parts.lib.mkFlake { inherit inputs; } (inputs.import-tree ./modules/flake);
}
