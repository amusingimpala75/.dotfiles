{
  lib,
  config,
  pkgs,
  userSettings,
  ...
}:
let
  package = if pkgs.stdenv.isDarwin then pkgs.firefox-bin else pkgs.firefox;
  profile = "default-release";
in
{
  programs.firefox = {
    inherit package;
    enable = true;
    profiles.${profile} = {
      id = 0;
      name = profile;
      isDefault = true;
      search = {
        default = "DuckDuckGo";
        force = true;
      };
      settings = {
        "app.update.channel" = "default"; # TODO prevent autoupdate
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
        packages = with pkgs.nur.repos.rycee.firefox-addons; [
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

  textfox = {
    enable = true;
    inherit profile;
  };

  home.activation.default-browser = lib.mkIf pkgs.stdenv.isDarwin (
    lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      ${pkgs.defaultbrowser}/bin/defaultbrowser firefox
    ''
  );
}
