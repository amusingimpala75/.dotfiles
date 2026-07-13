{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:
{
  imports = [
    # rices
    ./rices/cross.nix
    ./rices/grey.nix
    ./rices/gruvbox.nix
    ./rices/nord.nix
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
      padding = lib.mkOption {
        description = "padding of bar widgets";
        default = 4;
      };
    };

    emacs = {
      theme-package = lib.mkOption {
        description = "package to use";
        default = epkgs: (pkgs.mkBase16EmacsTheme.override { emacsPackages = epkgs; }) config.rice.theme;
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

  config.nixpkgs.overlays = [
    (final: _: {
      nix-wallpaper = inputs.nix-wallpaper.packages.${final.stdenv.hostPlatform.system}.default;
    })
  ];
}
