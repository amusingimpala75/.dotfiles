{
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.my.ghostty;
  rice = config.rice;
in
{
  imports = [ ./darwin.nix ];

  options.my.ghostty = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      example = true;
      description = "enable ghostty configuration";
    };
  };

  config = lib.mkIf cfg.enable {
    programs.ghostty = {
      package = if pkgs.stdenv.isLinux then pkgs.ghostty else pkgs.ghostty-bin;
      enable = true;
      settings = with rice; {
        background-opacity = "${toString opacity}";
        background-blur-radius = 10;

        selection-invert-fg-bg = true;
        window-theme = "system";

        font-family = "${toString font.family.fixed-pitch}";
        font-thicken = true;
        font-size = "${toString font.size}";

        mouse-hide-while-typing = true;
        cursor-style = "block";
        shell-integration-features = "no-cursor";

        quit-after-last-window-closed = true;

        macos-titlebar-style = "hidden";
        macos-option-as-alt = true;

        command = config.my.cli.defaultShell;

        auto-update = "off";

        theme = "base16";
      };
      themes = {
        base16 = with config.rice.theme; {
          background = "${base00}";
          foreground = "${base06}";
          palette = [
            "0=#${base00}"
            "1=#${base08}"
            "2=#${base0B}"
            "3=#${base0A}"
            "4=#${base0D}"
            "5=#${base0E}"
            "6=#${base0C}"
            "7=#${base05}"
            "8=#${base08}"
            "9=#${base03}"
            "10=#${base08}"
            "11=#${base0B}"
            "12=#${base0A}"
            "13=#${base0D}"
            "14=#${base0E}"
            "15=#${base0C}"
            "16=#${base07}"
            "17=#${base09}"
            "18=#${base0F}"
            "19=#${base01}"
            "20=#${base02}"
            "21=#${base04}"
            "22=#${base06}"
          ];
        };
      };
    };
  };
}
