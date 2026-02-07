{
  config,
  lib,
  pkgs,
  self,
  ...
}:
{
  imports = with self.modules.homeManager; [
    pi
  ];

  home.username = "lukemurray";

  my = {
    aerospace.enable = true;
    cli = {
      defaultShell = "zsh";
      enable = true;
    };
    emacs = {
      enable = true;
      term-command =
        let
          pkg = (pkgs.writeScriptBin "emacs-term" (builtins.readFile ./emacs-term.sh)).overrideAttrs (old: {
            buildCommand = "${old.buildCommand}\n patchShebangs $out";
          });
        in
        "${pkg}/bin/emacs-term";
    };
    firefox.enable = true;
    games.brogue.enable = true;
    games.brogue.terminal = true;
    games.minecraft.gui.enable = true;
    vcs = {
      git = true;
      jujutsu = true;
      email = "69653100+amusingimpala75@users.noreply.github.com";
      username = "amusingimpala75";
    };
    ghostty.enable = true;
    jankyborders.enable = true;
  };

  programs.nix-index.enable = false;

  programs.tmux.terminal = lib.mkForce "xterm-ghostty";

  infat = {
    enable = true;
    associations = {
      # the discard is fine since the package is installed anyways
      "${builtins.unsafeDiscardStringContext config.my.emacs.package}/Applications/Emacs.app" = [
        ".org"
        ".yaml"
      ];
    };
  };

  rices.cross.enable = true;

  home.packages =
    with pkgs;
    [
      jq
      ntfy-sh
      yq-go

      infat
      wireshark
    ]
    ++ lib.optionals pkgs.stdenv.isDarwin (with pkgs; [
      # Emacs implicitly calls these,
      # which pulls up a warning from macOS
      # if `xcode-install --select` isn't run first
      gcc
      git
      # macOS utilities
      darwin.trash # TODO cross-platform
      # Casks
      brewCasks."8bitdo-ultimate-software-v2"
      brewCasks.balenaetcher
      # brewCasks.battle-net # failing for unknown reason
      # brewCasks.dwarf-fortress-lmp # weird path confirmation issues
      brewCasks.gimp
      brewCasks.hytale
      brewCasks.imazing
      brewCasks.inkscape
      # brewCasks.jd-gui # can't find java?
      brewCasks.minecraft
      brewCasks.qlmarkdown
      brewCasks.raspberry-pi-imager
      brewCasks.steam
      # brewCasks.tailscale-app # invalid archive here, doesn't launch if from nixpkgs
      brewCasks.ti-connect-ce
    ]);

  # See both mynixos.com options for nix-darwin and home-manager, as well as macos-defaults.com
  # Additionally, `defaults read' will list out current settings
  # Alternately all settings can be found at ~/Library/Preferences/<app-id>.plist
  targets.darwin.defaults = lib.mkIf pkgs.stdenv.isDarwin {
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

  home.activation = lib.mkIf pkgs.stdenv.isDarwin {
    restart-dock = lib.hm.dag.entryAfter [ "setDarwinDefaults" ] ''
      /usr/bin/killall Dock
    '';
    load-settings = lib.hm.dag.entryAfter [ "setDarwinDefaults" ] ''
      /System/Library/PrivateFrameworks/SystemAdministration.framework/Resources/activatesettings -u
    '';
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
}
