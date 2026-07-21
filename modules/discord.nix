{
  flake.modules.homeManager.discord = {
    programs.vesktop = {
      enable = true;
      settings = {
        appBadge = true;
        arRPC = true;
        autoStartMinimized = true;
        clickTrayToShowHide = true;
        disableMinSize = false;
        disableSmoothScroll = false;
        discordBranch = "stable";
        enableMenu = false;
        enableRoundedCorners = true;
        enableShadow = true;
        enableSplashScreen = false;
        enableTaskbarFlashing = false;
        hardwareAcceleration = true;
        hardwareVideoAcceleration = true;
        minimzeToTray = true;
        nativeTitleBar = false;
        openLinkWithElectron = false;
        staticTitle = false;
        transparencyOption = "mica";
        tray = true;
        webRTCIPHandlingPolicy = "default";
      };
    };
  };
}
