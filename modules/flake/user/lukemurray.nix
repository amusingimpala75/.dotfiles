{
  self,
  ...
}:
{
  flake.homeConfigurations = self.lib.mkHome "aarch64-darwin" "lukemurray" (
    {
      pkgs,
      ...
    }:
    {
      imports = with self.modules.homeManager; [
        breaktime
        brew
        brogue
        cli
        direnv
        emacs
        firefox
        ghostty
        git
        hister
        jujutsu
        minecraft
        ng-cli
        ng-nix
        pi
        radicle
        scrolling
        vcs
        wallust
        window-borders
        zsh
      ];

      programs.radicle.settings.node.alias = "amusingimpala75@finarfin";

      my.sketchybar.enable = true;

      vcs = {
        email = "69653100+amusingimpala75@users.noreply.github.com";
        username = "amusingimpala75";
      };

      rices.cross.enable = true;

      home.packages = with pkgs; [
        play-audio
        # Emacs implicitly calls these,
        # which pulls up a warning from macOS
        # if `xcode-install --select` isn't run first
        gcc
        # macOS utilities
        darwin.trash # TODO cross-platform
        unquarantine
        screen-saver
        run-ntfy-when-done
        # Casks
        brewCasks."8bitdo-ultimate-software-v2"
        brewCasks.gimp
        brewCasks.qlmarkdown
        brewCasks.steam
        # brewCasks.tailscale-app # invalid archive here, doesn't launch if from nixpkgs
      ];

      # See both mynixos.com options for nix-darwin and home-manager, as well as macos-defaults.com
      # Additionally, `defaults read' will list out current settings
      # Alternately all settings can be found at ~/Library/Preferences/<app-id>.plist
      targets.darwin.defaults = {
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

      my.darwin.dock.items = [
        # Finder
        "/System/Applications/Messages.app"
        "/System/Applications/Mail.app"
        "/System/Applications/Maps.app"
        "/System/Applications/FaceTime.app"
        "/System/Applications/Calendar.app"
        "/Applications/Pages.app"
        "/System/Applications/App Store.app"
        "/System/Applications/System Settings.app"
        "~/Applications/Home Manager Apps/Firefox.app"
        "~/Applications/Home Manager Apps/Emacs.app"
        "~/Applications/Home Manager Apps/Ghostty.app"
        "/System/Applications/iPhone Mirroring.app"
        "~/Downloads"
      ];

      home.stateVersion = "24.05";
    }
  );
}
