{ lib, ... }:
{
  imports = [
    # compat
    ./darwin.nix
    # rices
    ./rices/woodland.nix
    ./rices/solarized-light.nix
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
      active = lib.mkOption { description = "color of active window border"; };
      inactive = lib.mkOption { description = "color of inactive window border"; };
      width = lib.mkOption { description = "width of window border"; };
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
  };
}
