{ pkgs, ... }:
{
  home.username = "murrayle23";

  my = {
    cli.enable = true;
    emacs.enable = true;
    firefox.enable = true;
    games = {
      brogue.enable = true;
    };
    vcs = {
      git = true;
      jujutsu = true;
      email = "69653100+amusingimpala75@users.noreply.github.com";
      username = "amusingimpala75";
    };
    wezterm.enable = true;
  };

  rices.gruvbox.enable = true;

  wsl.username = "MURRAYLE23";
  wsl.wallp.enable = true;

  home.packages = [
    pkgs.noto-fonts-color-emoji
  ];
}
