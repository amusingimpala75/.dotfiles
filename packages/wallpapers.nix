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
  };
in builtins.mapAttrs (name: value: fetchurl value) wps
