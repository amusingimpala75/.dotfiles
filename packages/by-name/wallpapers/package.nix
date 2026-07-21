{
  fetchurl,
  fetchMTGWallpaper,
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
    "nord-buildings" = {
      url = "https://raw.githubusercontent.com/linuxdotexe/nordic-wallpapers/master/wallpapers/nord_buildings.png";
      hash = "sha256-diUciJI5D+Os/dqG7pjc5T47QYzFoWwDJjr8a0WfFlc=";
    };
  };
in
(builtins.mapAttrs (_: fetchurl) wps)
// {
  "simple-cross" = ./cross_wallpaper.png;
  "bakersbane-duo" = fetchMTGWallpaper {
    set = "blb";
    number = "163";
    hash = "sha256-/42c/XC5UNOVkSQcEv4IrrGqPikMqB5xoGqs83hvOnY=";
  };
}
