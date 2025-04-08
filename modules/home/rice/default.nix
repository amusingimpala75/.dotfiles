{ config, lib, pkgs, ... }:
{
  imports = [
    # compat
    ./darwin.nix
    # rices
    ./rices/solarized-light.nix
    ./rices/winnie-farming.nix
    ./rices/woodland.nix
  ];

  # :TODO: expand option docs
  options.rice = {
    theme = lib.mkOption { description = "color scheme to use"; };

    opacity = lib.mkOption { description = "opacity of windows"; };

    font = {
      family.fixed-pitch = lib.mkOption { description = "name of fixed-space font family"; };
      family.variable-pitch = lib.mkOption { description = "name of variable-space font family"; };
      size = lib.mkOption { description = "size of font"; };
    };

    border = {
      active = lib.mkOption {
        description = "color of active window border";
        default = config.rice.theme.base0E;
      };
      inactive = lib.mkOption {
        description = "color of inactive window border";
        default = config.rice.theme.base02;
      };
      width = lib.mkOption { description = "width of window border"; };
      radius = lib.mkOption {
        description = "corner radius";
        default = 0;
      };
    };

    gaps = {
      inner = lib.mkOption { description = "width of inner gaps"; };
      outer = lib.mkOption { description = "width of outer gaps"; };
    };

    bar = {
      isTop = lib.mkOption { description = "placement of bar at top"; };
      height = lib.mkOption { description = "height of bar"; };
      color = lib.mkOption { description = "bg of bar"; };
    };

    wallpaper = lib.mkOption {
      description = "wallpaper image to use";
      default = let
        pkg = pkgs.nix-wallpaper.override {
          backgroundColor = "#${config.rice.theme.base01}";
          logoColors = lib.genAttrs ["color0" "color1" "color2" "color3" "color4" "color5"]
          (name: "#${config.rice.theme.base05}");
        };
      in
      "${pkg}/share/wallpapers/nixos-wallpaper.png";
    };

    emacs = {
      theme-package = lib.mkOption {
        description = "package to use";
        default = pkgs.my.base16-generators.emacs config.rice.theme;
      };
      theme-file-name = lib.mkOption {
        description = "name of file to be `require'd";
        default = "my-base16-theme";
      };
      theme-name = lib.mkOption {
        description = "name of theme to use";
        default = "my-base16";
      };
    };
  };
}
