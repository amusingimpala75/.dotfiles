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
  };
  outputs =
    {
      self,
      nixpkgs,
      nixpkgs-stable-darwin,
      nixpkgs-stable-nixos,
      nix-darwin,
      nixos-wsl,
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
          inputs.emacs-overlay.overlays.default
          inputs.nix-darwin-firefox.overlay
          inputs.nur.overlays.default
          (final: prev: {
            stable =
              if prev.stdenv.isDarwin then
              nixpkgs-stable-darwin.legacyPackages.${prev.system}
              else
              nixpkgs-stable-nixos.legacyPackages.${prev.system};

              ghostty-bin = final.callPackage ./packages/ghostty.nix { };
              whisky-bin = final.callPackage ./packages/whisky.nix { };
              my.launcher = final.callPackage ./packages/launcher.nix { };
              scriptWrapper = final.callPackage ./packages/scriptWrapper.nix { };
              float_and = final.callPackage ./packages/float_and.nix { };
              ghostty_and = final.callPackage ./packages/ghostty_and.nix { };
          })
          inputs.sbarlua.overlay
        ];
      };
      getHostArchitecture = system: import ./system/${system}/system.nix;
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
          sys = getHostArchitecture system;
        in
        nix-darwin.lib.darwinSystem {
          system = sys.arch;
          specialArgs = inputs;
          modules = [
            { nixpkgs = nixpkgsConfig; }
            ./system/${system}
          ];
        }
      );
      nixosConfigurations = lib.genAttrs nixosHosts (
        system:
        let
          sys = getHostArchitecture system;
        in
        nixpkgs.lib.nixosSystem {
          system = sys.arch;
          specialArgs = inputs;
          modules = [
            { nixpkgs = nixpkgsConfig; }
            ./system/${system}
          ] ++ (if sys.wsl then [ nixos-wsl.nixosModules.default ] else [ ]);
        }
      );
      homeConfigurations = lib.genAttrs userHosts (
        userHost:
        let
          userHostPair = lib.strings.splitString userHostPairSeparator userHost;
          user = builtins.elemAt userHostPair 0;
          system = builtins.elemAt userHostPair 1;
          sys = import ./system/${system}/system.nix;
        in
        home-manager.lib.homeManagerConfiguration {
          pkgs = import nixpkgs (nixpkgsConfig // { system = sys.arch; });
          modules = [
            ./user/${user}
            inputs.textfox.homeManagerModules.default
          ];
          extraSpecialArgs = inputs // {
            username = user;
            dotfilesDir = dotfilesDir;
            hostname = system;
            userSettings = import ./user/${user}/settings.nix;
          };
        }
      );
      packages = forAllSystems (
        platform:
        let
          pkgs = import nixpkgs (nixpkgsConfig // { system = platform; });
        in
        {
          default = self.packages.${platform}.installer;

          emacs = (import ./module/app/emacs/package.nix) pkgs {
            opacity = 0.8;
            font = import ./module/font/iosevka; # TODO this will need to be fixed
            theme = import ./module/theme/generated/gruvbox-dark-medium;
          };

          installer = pkgs.writeShellApplication {
            name = "install";
            text = ''${./install.sh} "$@"'';
          };
        }
      );
      apps = forAllSystems (platform: {
        default = self.apps.${platform}.installer;

        emacs = {
          type = "app";
          program = "${self.packages.${platform}.emacs}/bin/emacs";
        };

        installer = {
          type = "app";
          program = "${self.packages.${platform}.installer}/bin/install";
        };
      });
    };
}
