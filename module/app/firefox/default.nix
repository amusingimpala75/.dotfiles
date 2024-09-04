{ lib, config, pkgs, userSettings, ...}:

# TODO: de-darwin-ize the config
{
  # Otherwise it will not start on macOS, pending fix in HM
  # Requires opening Firefox from cli, not gui
  home.sessionVariables = {
    MOZ_LEGACY_PROFILES = 1;
  };

  programs.firefox = {
    enable = true;
    package = pkgs.firefox-bin;
    profiles.default-release = {
      id = 0;
      name = "default-release";
      isDefault = true;
      userChrome = builtins.readFile ./userChrome.css;
      search.default = "DuckDuckGo";
      settings = {
        # "app.update.channel" = "default"; # TODO prevent autoupdate
        "extensions.autoDisableScopes" = 0;
        "sidebar.revamp" = true;
        "sidebar.verticalTabs" = true;
        "sidebar.visibility" = "hide-sidebar";
        "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
        "trailhead.firstrun.didSeeAboutWelcome" = true;
      };
      extensions = with pkgs.nur.repos.rycee.firefox-addons; [
        darkreader
        enhanced-github
        gaoptout
        github-file-icons
        gruvbox-dark-theme # TODO integrate with theme system
        istilldontcareaboutcookies
        simple-tab-groups
        sponsorblock
        ublock-origin
        untrap-for-youtube
        vimium
      ];
    };
  };

  home.activation.default-browser = lib.hm.dag.entryAfter ["writeBoundary"] ''
    ${pkgs.defaultbrowser}/bin/defaultbrowser firefox
  '';
}
