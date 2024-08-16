{
  description = "My system configurations for macOS, WSL, and NixOS";
  inputs = {
    nixpkgs.url = "nixpkgs/nixpkgs-unstable";
    nixpkgs-stable-darwin.url = "nixpkgs/nixpkgs-24.05-darwin";

    nix-darwin.url = "github:LnL7/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    emacs-overlay.url = "github:nix-community/emacs-overlay";
    emacs-overlay.inputs.nixpkgs.follows = "nixpkgs";

    alacritty-theme.url = "github:alexghr/alacritty-theme.nix";
    alacritty-theme.inputs.nixpkgs.follows = "nixpkgs";
  };
  outputs = { self, nixpkgs, nixpkgs-stable-darwin, nix-darwin, home-manager, emacs-overlay, alacritty-theme }@inputs: let
    lib = nixpkgs.lib;
    users = [ "lukemurray" ];
    darwinHosts = [ "Lukes-Virtual-Machine" ];
    userHostPairSeparator = "_";
    userHosts = builtins.foldl' (x: y: x ++ y) [] (lib.lists.forEach users (user: lib.lists.forEach darwinHosts (host: user + userHostPairSeparator + host )));
    dotfilesDir = "~/.dotfiles";
  in {
    darwinConfigurations = lib.genAttrs darwinHosts (system:
      nix-darwin.lib.darwinSystem {
        system = import ./system/${system}/system.nix;
	specialArgs = inputs;
	modules = [
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
	pkgs = (import nixpkgs {
	  system = sys;
	  config.allowUnfree = true;
	  overlays = [ alacritty-theme.overlays.default ];
	});
      in
      home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
	modules = [
	  ./user/${user}
	];
	extraSpecialArgs = inputs // {
	  username = user;
	  dotfilesDir = dotfilesDir;
	  hostname = system;
	};
      }
    );
  };
}