{ config ? {}, inputs, lib, pkgs, ... }:
let
  # TODO there's probably a better way to do this
  isHomeManager = builtins.hasAttr "home" config;
  isNixDarwin = builtins.hasAttr "homebrew" config;
  isNixOS = !isHomeManager && !isNixDarwin;
in {
  config.nix = {
    settings = {
      experimental-features = [ "nix-command" "flakes" ];
      flake-registry = "";
    };
    package = pkgs.nixVersions.nix_2_28;
    registry = lib.mapAttrs (_: flake: { inherit flake; }) inputs;
    nixPath = lib.mapAttrsToList(n: _: "${n}=flake:${n}") inputs;
    # channel.enable = false; # Do I want to disable channels?
    gc = {
      automatic = true;
      options = "--delete-older-than 30d";
    } // (lib.optionalAttrs isNixOS {
      persistent = true;
      dates = "weekly";
    }) // (lib.optionalAttrs isHomeManager {
      persistent = true;
      frequency = "weekly";
    }) // (lib.optionalAttrs isNixDarwin {
      interval = {
        Weekday = 7;
        Hour = 3;
        Minute = 15;
      };
    });
  };
}
