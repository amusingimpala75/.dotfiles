{ lib, config, pkgs, username, hostname, dotfilesDir, userSettings, ... }:

# TODO: add wallpaper (both with nix-wallpaper,
#       and with some custom way to set the Index.plist
{
  imports = [
    ../../module/desktop/aerospace
    ../../module/desktop/jankyborders
    ../../module/desktop/sketchybar
    ../../module/font
    ../../module/theme
  ];

  my.bat.enable = true;

  my.direnv.enable = true;

  my.emacs.enable = true;
  my.emacs.term-command = "TERM=alacritty-direct emacsclient -nw"; # :TODO: this shouldn't be necessary ultimately

  my.firefox.enable = true;

  my.git = {
    enable = true;
    email = "69653100+amusingimpala75@users.noreply.github.com";
    username = "amusingimpala75";
  };

  my.ghostty = {
    enable = true;
    package = null; # TODO fix weird errors on macOS with ghostty managed by us (see the module for :TODO: comment)
  };

  my.nix.enable = true;

  my.spotify.enable = true;

  my.zsh.enable = true;

  theme = userSettings.theme; # TODO import directly here after we banish userSettings

  home.packages = with pkgs; [
    (bible.asv.override { grepCommand = "${pkgs.ripgrep}/bin/rg"; })
    chafa
    fd
    fzf
    jq
    ripgrep
    scc # SLOC counting
    tealdeer
    tree
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

  home.shellAliases = {
    ll = "ls -lah";
  };

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
}
