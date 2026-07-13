{
  self,
  ...
}:
{
  flake.modules.darwin.lukemurray =
    {
      config,
      pkgs,
      ...
    }:
    {
      users.users.lukemurray = {
        createHome = true;
        home = "/Users/lukemurray";
        shell = pkgs.zsh;
        packages =
          with pkgs;
          [
            play-audio
            gcc # for emacs?
            darwin.trash
            unquarantine
            screen-saver
            run-ntfy-when-done
          ]
          ++ (with pkgs.brewCasks; [
            brewCasks."8bitdo-ultimate-software-v2"
            gimp
            qlmarkdown
            steam
            # tailscale-app
          ]);
      };
      # [TODO] I long for the day nix-darwin finishes the
      # migration and I can roll the defaults into the
      # user definition
      system.primaryUser = "lukemurray";
      system.defaults.dock.persistent-apps = [
        # Finder
        "/System/Applications/Messages.app"
        "/System/Applications/Mail.app"
        "/System/Applications/Maps.app"
        "/System/Applications/FaceTime.app"
        "/System/Applications/Calendar.app"
        "/Applications/Pages.app"
        "/System/Applications/App Store.app"
        "/System/Applications/System Settings.app"
        "${config.users.users.lukemurray.home}/Applications/Home Manager Apps/Firefox.app"
        "${config.users.users.lukemurray.home}/Applications/Home Manager Apps/Emacs.app"
        "${config.users.users.lukemurray.home}/Applications/Home Manager Apps/Ghostty.app"
        "/System/Applications/iPhone Mirroring.app"
        "${config.users.users.lukemurray.home}/Downloads"
      ];
    };

  flake.homeConfigurations = self.lib.mkHome "aarch64-darwin" "lukemurray" (
    {
      lib,
      pkgs,
      ...
    }:
    {
      imports = with self.modules.homeManager; [
        breaktime
        cli
        direnv
        emacs
        firefox
        ghostty
        git
        jujutsu
        neko
        minecraft
        ng-cli
        ng-nix
        pi
        radicle
        scrolling
        sketchybar
        vcs
        wallust
        window-borders
        zsh
      ];

      programs.radicle.settings.node.alias = "amusingimpala75@finarfin";

      vcs = {
        email = "69653100+amusingimpala75@users.noreply.github.com";
        username = "amusingimpala75";
      };

      programs.vesktop.enable = true;

      targets.darwin = {
        copyApps.enable = true;
        linkApps.enable = false;

        # See both mynixos.com options for nix-darwin and home-manager, as well as macos-defaults.com
        # Additionally, `defaults read' will list out current settings
        # Alternately all settings can be found at ~/Library/Preferences/<app-id>.plist
        defaults = {
          "com.apple.dock" = {
            autohide = true;
            largesize = 96;
            magnification = true;
            mru-spaces = false;
            orientation = "bottom";
            show-recents = false;
          };
          "com.apple.finder" = {
            AppleShowAllExtensions = true;
            AppleShowAllFiles = true; # Requires finder to be killed
            CreateDesktop = false;
            FXDefaultSearchScope = "SCcf";
            FXEnableExtensionChangeWarning = false; # Requires finder to be killed
            FXPreferredViewStyle = "clmv";
            FXRemoveOldTrashItems = false;
            _FXSortFoldersFirst = false;
            ShowPathbar = true;
            ShowStatusBar = true;
          };
          "NSGlobalDomain" = {
            # AppleInterfaceStyle # This doesn't seem to work
            InitialKeyRepeat = 10;
            KeyRepeat = 1;
          };
        };
      };

      home.activation.load-settings = lib.mkIf pkgs.stdenv.hostPlatform.isDarwin (
        lib.hm.dag.entryAfter [ "setDarwinDefaults" ] ''
          /System/Library/PrivateFrameworks/SystemAdministration.framework/Resources/activatesettings -u
        ''
      );

      home.stateVersion = "24.05";
    }
  );
}
