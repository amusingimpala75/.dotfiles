{ lib, config, pkgs, userSettings, ...}:

{
  # This will have to wait a few weeks once we're out of beta.
  # home.packages = [ pkgs.ghostty ];

  home.file.".hushlogin".text = lib.mkIf pkgs.stdenv.isDarwin "";
  
  home.file.".config/ghostty/config".text = (with userSettings; ''
    background = ${theme.base00}
    foreground = ${theme.base06}

    palette = 0=#${theme.base00}
    palette = 1=#${theme.base08}
    palette = 2=#${theme.base0B}
    palette = 3=#${theme.base0A}
    palette = 4=#${theme.base0D}
    palette = 5=#${theme.base0E}
    palette = 6=#${theme.base0C}
    palette = 7=#${theme.base05}
    palette = 8=#${theme.base08}
    palette = 9=#${theme.base03}
    palette = 10=#${theme.base08}
    palette = 11=#${theme.base0B}
    palette = 12=#${theme.base0A}
    palette = 13=#${theme.base0D}
    palette = 14=#${theme.base0E}
    palette = 15=#${theme.base0C}
    palette = 16=#${theme.base07}
    palette = 17=#${theme.base09}
    palette = 18=#${theme.base0F}
    palette = 19=#${theme.base01}
    palette = 20=#${theme.base02}
    palette = 21=#${theme.base04}
    palette = 22=#${theme.base06}

    background-opacity = ${toString opacity}
    background-blur-radius = 10

    selection-invert-fg-bg = true
    window-theme = system

    font-family = ${toString font.family.fixed-pitch}
    font-thicken = true
    font-size = ${toString font.size}

    mouse-hide-while-typing = true
    cursor-style = block
    shell-integration-features = no-cursor

    quit-after-last-window-closed = true

    # macos-titlebar-style = hidden
    window-decoration = false
    macos-option-as-alt = true

    # TODO genericize
    shell-integration = zsh
    command = ${pkgs.zsh}/bin/zsh
  '');
}
