{ pkgs, userSettings, ... }:
{
  imports = [
    ../../../modules/font
    ../../../modules/theme
  ];

  home.packages = with pkgs; [
    (bible.asv.override { grepCommand = "${pkgs.ripgrep}/bin/rg"; })
    fastfetch
    fd
    ripgrep
    scc
    tree
    yq-go
  ];

  my.bat.enable = true;

  my.direnv.enable = true;

  my.emacs.enable = true;

  my.firefox.enable = true;

  my.git = {
    enable = true;
    email = "69653100+amusingimpala75@users.noreply.github.com";
    username = "amusingimpala75";
  };

  my.nix.enable = true;

  my.zsh.enable = true;

  theme = userSettings.theme; # TODO import directly here after we banish userSettings

  home.shellAliases = {
    ll = "ls -lah";
  };
}
