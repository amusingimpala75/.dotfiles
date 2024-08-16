{ config, pkgs, username, hostname, dotfilesDir, ... }:

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
}
