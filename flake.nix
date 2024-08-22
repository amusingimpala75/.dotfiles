{
  description = "My system configurations for macOS, WSL, and NixOS";
  inputs = {
    nixpkgs.url = "nixpkgs/nixpkgs-unstable";
    nixpkgs-stable-darwin.url = "nixpkgs/nixpkgs-24.05-darwin";
    nixpkgs-stable-nixos.url = "nixpkgs/nixos-24.05";

    nix-darwin.url = "github:LnL7/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    emacs-overlay.url = "github:nix-community/emacs-overlay";
    emacs-overlay.inputs.nixpkgs.follows = "nixpkgs";

    alacritty-theme.url = "github:alexghr/alacritty-theme.nix";
    alacritty-theme.inputs.nixpkgs.follows = "nixpkgs";
  };
  outputs = { self, nixpkgs, nixpkgs-stable-darwin, nixpkgs-stable-nixos, nix-darwin, home-manager, ... }@inputs: let
    lib = nixpkgs.lib;
    users = [ "lukemurray" ];
    darwinHosts = [ "Lukes-Virtual-Machine" ];
    userHostPairSeparator = "_";
    userHosts = builtins.foldl' (x: y: x ++ y) [] (lib.lists.forEach users (user: lib.lists.forEach darwinHosts (host: user + userHostPairSeparator + host )));
    dotfilesDir = "~/.dotfiles";
    nixpkgsConfig = {
      config.allowUnfree = true;
      overlays = [
        inputs.alacritty-theme.overlays.default
        inputs.emacs-overlay.overlays.default
        (final: prev: {
          stable = if prev.stdenv.isDarwin then nixpkgs-stable-darwin.legacyPackages.${prev.system} else nixpkgs-stable-nixos.legacyPackages.${prev.system};
        })
      ];
    };
    getHostArchitecture = system: import ./system/${system}/system.nix;
  in {
    darwinConfigurations = lib.genAttrs darwinHosts (system:
    let
      sys = getHostArchitecture system;
    in
    nix-darwin.lib.darwinSystem {
      system = sys;
	    specialArgs = inputs;
	    modules = [
	      { nixpkgs = nixpkgsConfig; }
	      ./system/${system}
	    ];
    }
    );
    homeConfigurations = lib.genAttrs userHosts (userHost:
    let 
    userHostPair = lib.strings.splitString userHostPairSeparator userHost;
	  user = builtins.elemAt userHostPair 0;
    system = builtins.elemAt userHostPair 1;
    sys = import ./system/${system}/system.nix;
    in
    home-manager.lib.homeManagerConfiguration {
      pkgs = import nixpkgs (nixpkgsConfig // { system = sys; });
	    modules = [
	      ./user/${user}
	    ];
	    extraSpecialArgs = inputs // {
	      username = user;
	      dotfilesDir = dotfilesDir;
	      hostname = system;
	      userSettings = import ./user/${user}/settings.nix;
	    };
    }
    );
  };
}
