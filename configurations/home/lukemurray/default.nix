{ lib, pkgs, ... }:
{
  home.username = "lukemurray";

  my = {
    aerospace.enable = true;
    cli.enable = true;
    emacs = {
      enable = true;
      term-command = "TERM=alacritty-direct emacsclient -nw"; # :TODO: this shouldn't be necessary ultimately
    };
    firefox.enable = true;
    games.brogue.enable = true;
    git = {
      enable = true;
      email = "69653100+amusingimpala75@users.noreply.github.com";
      username = "amusingimpala75";
    };
    ghostty = {
      enable = true;
      package = null; # TODO fix weird errors on macOS with ghostty managed by us (see the module for :TODO: comment)
    };
    jankyborders.enable = true;
    sketchybar.enable = true;
    spotify.enable = true;
  };

  rices.winnie-farming.enable = true;

  home.packages = with pkgs; [
    pkgs.zen
    jq
    yq-go
  ] ++ lib.optionals pkgs.stdenv.isDarwin [
    # Emacs implicitly calls these,
    # which pulls up a warning from macOS
    # if `xcode-install --select` isn't run first
    pkgs.gcc
    pkgs.git
    # macOS only apps
    pkgs.utm
    pkgs.whisky-bin
    # macOS utilities
    pkgs.darwin.trash # TODO cross-platform
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
      # Need some fixing to some format
      # Spacers with:
      #  com.apple.dock persistent-apps -array-add '{"tile-type"="spacer-tile";}'
      # persistent-apps = [ #
      #   "/System/Library/Launchpad.app"
      # ];
      # persistent-others = [ #
      #   "/Users/${username}/Downloads"
      # ];
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

  home.activation = {
    restart-dock = lib.hm.dag.entryAfter ["setDarwinDefaults"] ''
      /usr/bin/killall Dock
    '';
    load-settings = lib.hm.dag.entryAfter ["setDarwinDefaults"] ''
      /System/Library/PrivateFrameworks/SystemAdministration.framework/Resources/activatesettings -u
    '';
  };

  my.darwin.dock.items = [
    # Finder
    "/System/Applications/Launchpad.app"
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
    "/Applications/Ghostty.app" # :TODO: still need to fix package
    "/System/Applications/iPhone Mirroring.app"
    "~/Downloads"
  ];
}
