{
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
  };
in builtins.mapAttrs (name: value: fetchurl value) wps
