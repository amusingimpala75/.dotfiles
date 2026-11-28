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
      imports = [
        "${inputs.home-manager}/modules/programs/firefox"
      ];

      programs.firefox = {
        configPath =
          if pkgs.stdenv.hostPlatform.isDarwin then
            "Library/Application Support/org.nixos.firefox"
          else
            ".mozilla/firefox";
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
              Nixpkgs = {
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
                definedAliases = [ "@nixpkgs" ];
              };
              Noogle = {
                urls = [
                  {
                    template = "https://noogle.dev/q/";
                    params = [
                      {
                        name = "term";
                        value = "{searchTerms}";
                      }
                    ];
                  }
                ];
                definedAliases = [ "@noogle" ];
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
                definedAliases = [ "@mynixos" ];
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
            "privacy.fingerprintingProtection" = true;
            "privacy.fingerprintingProtection.overrides" = "+AllTargets,-CSSPrefersColorScheme";
            "privacy.query_stripping.enabled" = true;
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
              # [TODO] vendor to get the auto-update functionality
              (pkgs.nur.repos.rycee.firefox-addons.buildFirefoxXpiAddon {
                pname = "nord-firefox";
                version = "3.0";
                addonId = "{f4c9e1d6-6630-4600-ad50-d223eab7f3e7}";
                url = "https://addons.mozilla.org/firefox/downloads/file/5070529/nord_firefox-3.0.xpi";
                sha256 = "sha256-O+7jj6Xa4Z8nld5aNhxkhSl2Jou9w6PhAxoARwyGS7I=";
                meta = {
                  description = "An arctic, north-bluish clean and elegant Mozilla Firefox theme.";
                  license = lib.licenses.cc-by-30;
                  mozPermissions = [ ];
                  platforms = lib.platforms.all;
                };
              })
              indie-wiki-buddy
              return-youtube-dislikes
              nopow
              sponsorblock
              ublock-origin
              vimium
              youtube-recommended-videos # unhook
            ];
            settings = {
              # Indie Wiki Buddy
              "{cb31ec5d-c49a-4e5a-b240-16c767444f62}".settings = {
                # for whatever reason this isn't actually read...
                searchEngineToggles.duckduckgo = "on";
                # Also somehow want to disable desktop notifications
              };
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
                netWhitelist = [
                  "chrome-extension-scheme"
                  "moz-extension-scheme"
                  "www.youtube.com"
                ];
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

      home.activation.default-browser = lib.mkIf pkgs.stdenv.hostPlatform.isDarwin (
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
