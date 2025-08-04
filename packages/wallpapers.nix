{
  callPackage,
  fetchurl,

  ...
}:
let
  wps = {
    "gruv-bunny" = {
      url = "https://gruvbox-wallpapers.pages.dev/wallpapers/minimalistic/bunny.png";
      hash = "sha256-3CK9IxFhzlbLURWua0EIg6YFN4CLtgkBawXOf6VIAIo=";
    };
    "winnie-the-pooh-farm" = {
      url = "https://wallpapercave.com/wp/wp13095000.jpg";
      hash = "sha256-v9GCbXDX0DG0gIGmumjiOf36kowC4oAfRfuKM/p8kjE=";
      curlOpts = "-A Mozilla";
    };
    "rainworld-slugcat-nest" = {
      url = "https://static.wikitide.net/rainworldwiki/c/c7/Survivor_intro_scene_2_%28branch%29.png";
      hash = "";
    };
    "rainworld-slugcat-family-wandering" = {
      url = "https://static.wikitide.net/rainworldwiki/9/9f/Survivor_intro_scene_4_%28walking%29.png";
      hash = "";
    };
    "rainworld-switch-promo" = {
      url = "https://static.wikitide.net/rainworldwiki/9/9c/Del-northern-rw-switch-promo.jpg";
      hash = "";
    };
    "monochrome-cross" = {
      url = "https://wallpaperaccess.com/download/minimalist-cross-4317563";
      hash = "";
    };
  };
  fetch-mtg = callPackage ./mtg-wallpaper.nix { };
in
(builtins.mapAttrs (name: value: fetchurl value) wps)
// {
  "simple-cross" = ./cross_wallpaper.png;
  "bakersbane-duo" = fetch-mtg {
    set = "blb";
    number = "163";
    hash = "sha256-/42c/XC5UNOVkSQcEv4IrrGqPikMqB5xoGqs83hvOnY=";
  };
}
