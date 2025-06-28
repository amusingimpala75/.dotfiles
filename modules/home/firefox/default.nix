{ lib, config, pkgs, inputs, ... }:
let
  cfg = config.my.firefox;
in
{
  imports = [
    ./darwin.nix
    inputs.textfox.homeManagerModules.default
  ];

  options.my.firefox = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      example = true;
      description = "Enable custom firefox config";
    };

    profile = lib.mkOption {
      type = lib.types.str;
      default = "default-release";
      example = "my-profile";
      description = "firefox profile into which to install";
    };

    textfox = lib.mkOption {
      type = lib.types.bool;
      default = true;
      example = false;
      description = "Enable textfox userChrome";
    };
  };

  config = lib.mkIf cfg.enable {
    programs.firefox = {
      enable = true;
      profiles.${cfg.profile} = {
        id = 0;
        name = cfg.profile;
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
          };
        };
        settings = {
          "app.update.auto" = false;
          "browser.newtabpage.activity-stream.feeds.section.topstories" = false;
          "browser.newtabpage.activity-stream.feeds.topsites" = false;
          "browser.newtabpage.activity-stream.feeds.wallpaperfeed" = false;
          "browser.newtabpage.activity-stream.feeds.weatherfeed" = false;
          "browser.startup.page" = 3;
          "browser.toolbars.bookmarks.visibility" = "newtab";
          "extensions.autoDisableScopes" = 0;
          "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
          "trailhead.firstrun.didSeeAboutWelcome" = true;
        };
        extensions = {
          force = true;
          packages =
            with pkgs.nur.repos.rycee.firefox-addons;
            [
              darkreader
              enhanced-github
              gaoptout
              github-file-icons
              gruvbox-dark-theme # TODO integrate with theme system
              istilldontcareaboutcookies
              # sideberry # done by textfox
              sponsorblock
              ublock-origin
              untrap-for-youtube
              vimium
            ];
            settings = {
              "uBlock0@raymondhill.net".settings = {
                selectedFilterLists = [
                  "user-filters"
                  "ublock-filters"
                  "ublock-badware"
                  "ublock-privacy"
                  "ublock-unbreak"
                  "ublock-quick-fixes"
                  "easylist"
                  "easyprivacy"
                  "urlhaus-1"
                  "plowe-0"
                ];
                user-filters = builtins.readFile ./ublock-filters.txt;
              };
            };
        };
      };
    };

    textfox = lib.mkIf cfg.textfox {
      enable = true;
      inherit (cfg) profile;
    };
  };
}
