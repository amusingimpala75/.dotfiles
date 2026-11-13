{
  flake.modules.homeManager.ghostty =
    {
      lib,
      pkgs,
      ...
    }:
    {
      home.packages = with pkgs; [
        custom-ghostty
        maple-mono.NF-CN-unhinted
      ];

      home.file.".hushlogin" = lib.mkIf pkgs.stdenv.hostPlatform.isDarwin { text = ""; };
    };

  flake.wrappers.ghostty =
    {
      wlib,
      ...
    }:
    {
      imports = [ wlib.wrapperModules.ghostty ];

      settings = {
        background-opacity = 0.9;
        background-blur-radius = 10;

        font-family = "Maple Mono NF CN";
        font-size = 16;
        font-thicken = true;

        selection-invert-fg-bg = true;
        window-theme = "system";
        theme = "wallust";

        mouse-hide-while-typing = true;
        cursor-style = "block";
        shell-integration-features = "no-cursor";

        command = "zsh";
        auto-update = "off";
        quit-after-last-window-closed = true;

        macos-titlebar-style = "hidden";
        macos-option-as-alt = true;
      };
    };
}
