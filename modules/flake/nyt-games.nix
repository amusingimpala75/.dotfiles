{
  flake.modules.homeManager.nyt-games =
    { pkgs, ... }:
    {
      programs.firefoxpwa = {
        enable = true;
        profiles."01KMNTJMYYTSXVV254WD47YNGK" = {
          name = "NYT Games";
          sites = {
            "01KMNTM2BKABTV3JF1SZDX44WQ" = {
              name = "Wordle";
              desktopEntry = {
                enable = true;
                icon = pkgs.fetchurl {
                  url = "https://www.nytimes.com/games-assets/v2/assets/wordle/page-icons/wordle-icon.svg";
                  hash = "sha256-g5q+KpUTFXeehM69GetM3YK4WGsLYh5bf35YXziayIg=";
                };
              };
              manifestUrl = "https://www.nytimes.com/games-assets/v2/metadata/wordle-web-manifest.json?v=";
              url = "https://www.nytimes.com/games/wordle/index.html";
            };
            "01KMNWK95X7HAGH8VX1SV3HHAG" = {
              name = "Connections";
              desktopEntry = {
                enable = true;
                icon = pkgs.fetchurl {
                  url = "https://www.nytimes.com/games-assets/v2/assets/icons/connections.svg";
                  hash = "sha256-H3Th8ATJVAHhl269pNhxs0LBKseJGg0cxsAyzhnva9w=";
                };
              };
              manifestUrl = "https://www.nytimes.com/games-assets/v2/metadata/connections-web-manifest.json?v=";
              url = "https://www.nytimes.com/games/connections";
            };
            "01KMNWKXR5WNQRW50654PNGQWK" = {
              name = "Strands";
              desktopEntry = {
                enable = true;
                icon = pkgs.fetchurl {
                  url = "https://www.nytimes.com/games-assets/v2/assets/icons/strands.svg";
                  hash = "sha256-9YLMk5ndCTr97lDbKnwaWMMVveo+IuwaWPzeMueA86w=";
                };
              };
              manifestUrl = "https://www.nytimes.com/games-assets/v2/metadata/strands-web-manifest.json?v=";
              url = "https://www.nytimes.com/games/strands";
            };
            "01KMNWM8A5GMSW11YF4WQH5271" = {
              name = "Pips";
              desktopEntry = {
                enable = true;
                icon = pkgs.fetchurl {
                  url = "https://www.nytimes.com/games-assets/v2/assets/icons/pips.svg";
                  hash = "sha256-7VGOH2dto75x3QEciio0QqJuVrMLlqfL0HkpRqJN04w=";
                };
              };
              manifestUrl = "https://www.nytimes.com/games-assets/v2/metadata/pips-web-manifest.json?v=";
              url = "https://www.nytimes.com/games/pips";
            };
          };
        };
      };
    };
}
