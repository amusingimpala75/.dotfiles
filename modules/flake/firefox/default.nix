{
  inputs,
  ...
}:
{
  flake.modules.homeManager.firefox =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    {
      programs.firefox = {
        enable = true;
        package = pkgs.bleeding.firefox;
        profiles."default-release" = {
          id = 0;
          name = "default-release";
          isDefault = true;
          search = {
            default = "ddg";
            force = true;
            engines = {
              "Nixpkgs" = {
                urls = [
                  {
                    template = "https://search.nixos.org/packages";
                    params = [
                      {
                        name = "query";
                        value = "{searchTerms}";
                      }
                      {
                        name = "type";
                        value = "packages";
                      }
                      {
                        name = "channel";
                        value = "unstable";
                      }
                    ];
                  }
                ];
                icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
                definedAliases = [ "@np" ];
              };
              MyNixOS = {
                urls = [
                  {
                    template = "https://mynixos.com/search";
                    params = [
                      {
                        name = "q";
                        value = "{searchTerms}";
                      }
                    ];
                  }
                ];
                definedAliases = [ "@mn" ];
              };
              Scryfall = {
                urls = [
                  {
                    template = "https://scryfall.com/search";
                    params = [
                      {
                        name = "q";
                        value = "{searchTerms}";
                      }
                    ];
                  }
                ];
                definedAliases = [ "@scry" ];
              };
            };
          };
          settings = {
            "app.update.auto" = false;
            "browser.aboutConfig.showWarning" = false;
            "browser.contentblocking.category" = "strict";
            "browser.download.autohideButton" = false;
            "browser.download.dir" = "${config.home.homeDirectory}/Downloads";
            "browser.newtabpage.activity-stream.feeds.section.topstories" = false;
            "browser.newtabpage.activity-stream.feeds.topsites" = false;
            "browser.newtabpage.activity-stream.feeds.wallpaperfeed" = false;
            "browser.newtabpage.activity-stream.feeds.weatherfeed" = false;
            "browser.newtabpage.enabled" = true;
            "browser.startup.page" = 3;
            "browser.tabs.warnOnClose" = false;
            "browser.toolbars.bookmarks.visibility" = "newtab";
            # [TODO] "browser.uiCustomization.state"
            # This causes it to load into safe mode without any extensions :sad:
            # "extensions.activeThemeID" = "{eb8c4a94-e603-49ef-8e81-73d3c4cc04ff}";
            "extensions.autoDisableScopes" = 0;
            "extensions.formautofill.addresses.enabled" = false;
            "extensions.formautofill.creditCards.enabled" = false;
            "extensions.pocket.enabled" = false;
            "network.IDN_show_punycode" = true;
            "privacy.donottrackheader.enabled" = true;
            "privacy.query_stripping.enabled" = true;
            "privacy.resistFingerprinting" = true;
            "privacy.trackingprotection.enabled" = true;
            "sidebar.verticalTabs" = true;
            "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
            "trailhead.firstrun.didSeeAboutWelcome" = true;
          };
          extensions = {
            force = true;
            packages = with pkgs.nur.repos.rycee.firefox-addons; [
              darkreader
              enhanced-github
              gaoptout
              github-file-icons
              gruvbox-dark-theme # TODO integrate with theme system
              sponsorblock
              ublock-origin
              vimium
              youtube-recommended-videos # unhook
            ];
            settings = {
              "uBlock0@raymondhill.net".settings = {
                selectedFilterLists = [
                  "easylist"
                  "easylist-annoyances"
                  "easylist-newsletters"
                  "easylist-notifications"
                  "easyprivacy"
                  "fanboy-cookiemonster"
                  "fanboy-social"
                  "fanboy-thirdparty_social"
                  "plowe-0"
                  "ublock-annoyances"
                  "ublock-badware"
                  "ublock-cookies-easylist"
                  "ublock-filters"
                  "ublock-privacy"
                  "ublock-quick-fixes"
                  "ublock-unbreak"
                  "urlhaus-1"
                  "user-filters"
                ];
                user-filters = builtins.readFile ./ublock-filters.txt;
              };
            };
          };
        };
      };

      nixpkgs.allowUnfreeList = [
        "gaoptout"
        "youtube-recommended-videos"
      ];

      nixpkgs.overlays = [
        inputs.nur.overlays.default
      ];

      home.activation.default-browser = lib.mkIf pkgs.stdenv.isDarwin (
        lib.hm.dag.entryAfter [ "writeBoundary" ] ''
          ${lib.getExe pkgs.defaultbrowser} firefox
        ''
      );
    };

  flake-file.inputs.nur = {
    url = "github:nix-community/NUR";
    inputs.nixpkgs.follows = "nixpkgs";
  };
}
