{
  lib,
  pkgs,
  self,
  ...
}:
{
  imports = with self.modules.homeManager; [
    brew
    ng-cli
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
    games = {
      brogue.enable = true;
      brogue.terminal = true;
      minecraft.gui.enable = true;
    };
    vcs = {
      git = true;
      jujutsu = true;
      email = "69653100+amusingimpala75@users.noreply.github.com";
      username = "amusingimpala75";
    };
    ghostty.enable = true;
    jankyborders.enable = true;
  };

  programs.infat = {
    enable = true;
    package = pkgs.infat.overrideAttrs (_: rec {
      # TODO remove once upstreamed into nixpkgs
      src = pkgs.fetchFromGitHub {
        owner = "philocalyst";
        repo = "infat";
        rev = "eed1108f042c1613a60eef4aa3bb80c44a7c86e7";
        hash = "sha256-4R/BB6WbMjuhUeBH1/kdSSvLnQTCTBihqt5STIu5cU0=";
      };
      cargoDeps = pkgs.rustPlatform.fetchCargoVendor {
        inherit src;
        hash = "sha256-/DHku1bryv5813NC0b2vdrP3Qvj8fu7C64//A9SmbIg=";
      };
    });
    settings = {
      extensions = {
        org = "Emacs";
        yaml = "Emacs";
        md = "Emacs";
      };
      schemes = {
        mailto = "Mail";
      };
      types = {
        plain-text = "Emacs";
      };
    };
  };

  rices.cross.enable = true;

  home.packages =
    with pkgs;
    [
      ntfy-sh
      play-audio
      cogfly

      wireshark
    ]
    ++ lib.optionals pkgs.stdenv.isDarwin (
      with pkgs;
      [
        # Emacs implicitly calls these,
        # which pulls up a warning from macOS
        # if `xcode-install --select` isn't run first
        gcc
        git
        # macOS Apps
        orbstack
        # macOS utilities
        darwin.trash # TODO cross-platform
        brightness
        jd-gui-duo
        unquarantine
        screen-saver
        run-ntfy-when-done
        # Casks
        brewCasks."8bitdo-ultimate-software-v2"
        brewCasks.balenaetcher
        # brewCasks.battle-net # failing for unknown reason
        # brewCasks.dwarf-fortress-lmp # weird path confirmation issues
        brewCasks.gimp
        brewCasks.imazing
        brewCasks.inkscape
        brewCasks.minecraft
        brewCasks.qlmarkdown
        brewCasks.raspberry-pi-imager
        brewCasks.steam
        # brewCasks.tailscale-app # invalid archive here, doesn't launch if from nixpkgs
        brewCasks.ti-connect-ce
      ]
    );

  nixpkgs.allowUnfreeList = [
    "orbstack"
  ];

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
}
