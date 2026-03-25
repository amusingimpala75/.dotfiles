{
  lib,
  inputs,
  pkgs,
  self,
  ...
}:
{
  imports = with self.modules.homeManager; [
    pi
  ];
  home.username = "murrayle23";

  my = {
    cli.enable = true;
    emacs.enable = true;
    games = {
      brogue.enable = true;
    };
    vcs = {
      git = true;
      jujutsu = true;
      email = "69653100+amusingimpala75@users.noreply.github.com";
      username = "amusingimpala75";
    };
  };

  rices.nord.enable = true;
  rice.font.size = lib.mkForce 20;

  wsl = {
    enable = true;
    username = "MURRAYLE23";
    wallp.enable = true;
  };

  services.podman.enable = true;

  home.packages = with pkgs; [
    noto-fonts-color-emoji
    get-win-sid
    play-audio
    wsl-open

    inputs.automader.packages.${pkgs.stdenv.hostPlatform.system}.automader
  ];
}
