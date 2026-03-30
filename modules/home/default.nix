{
  config,
  pkgs,
  self,
  ...
}:
let
  inherit (pkgs) stdenv;
in
{
  imports =
    with self.modules.homeManager;
    with self.modules.generic;
    [
      nixpkgs
      nix

      ./alacritty
      ./cli
      ./darwin
      ./direnv
      ./emacs
      ./firefox
      ./games
      ./ghostty
      ./nix
      ./rice
      ./sops
      ./spotify
      ./vcs
      ./wezterm
      ./wsl
      ./zsh
    ];

  config = {
    home.homeDirectory =
      if stdenv.isDarwin then "/Users/${config.home.username}" else "/home/${config.home.username}";
    home.stateVersion = "24.05"; # Kept for backwards compatibility

    programs.home-manager.enable = true;

    news.display = "silent";

    systemd.user.sessionVariables = config.home.sessionVariables;
  };
}
