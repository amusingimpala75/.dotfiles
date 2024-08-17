{ lib, config, pkgs, username, hostname, dotfilesDir, ... }:

# TODO: add wallpaper (both with nix-wallpaper,
#       and with some custom way to set the Index.plist
{
  home.username = username;
  home.homeDirectory = "/Users/${username}";
  home.stateVersion = "24.05";

  programs.home-manager.enable = true;

  home.packages = with pkgs; [
    iosevka
  ];

  fonts.fontconfig.enable = true;

  home.shellAliases = {
    ll = "ls -lah";
    reload-hm = "home-manager switch --flake ${dotfilesDir}#${username}_${hostname}";
    reload-nd = "darwin-rebuild switch --flake ${dotfilesDir}";
    reload-config = "reload-nd && reload-hm";
    vim = "emacsclient -nw";
    vi = "emacsclient -nw";
  };

  home.sessionVariables = {
    EDITOR="emacsclient -nw";
  };

  programs.zsh = {
    enable = true;
    dotDir = ".config/zsh";
    initExtra = ''
      export PROMPT="$USERNAME@%U$(hostname -s)%u> "
      export RPROMPT="%F{green}%~%f"
    '';
    autosuggestion = {
      enable = true;
      highlight = "bg=cyan,bold,underline";
    };
  };

  programs.alacritty = {
    enable = true;
    settings = {
      window = {
        # decorations = "Buttonless";
        padding = {
          x = 4;
          y = 4;
        };
        option_as_alt = "Both";
      };
      font.size = 14;
      font.normal = {
        family = "Iosevka";
        style = "Regular";
      };
      live_config_reload = true;
      import = [ pkgs.alacritty-theme.gruvbox_dark ];
    };
  };

  programs.git = {
    enable = true;
    ignores = [
      "*~"
    ];
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
      # persistent-apps = [
      #   "/System/Library/Launchpad.app"
      # ];
      # persistent-others = [
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
    # I've been told this makes it look better
    # "org.gnu.Emacs" = {
    #   AppleFontSmoothing = 0;
    # };
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
