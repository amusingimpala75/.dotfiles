{ config, lib, ... }:
let
  cfg = config.my.nix;
in {
  options.my.nix = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      example = false;
      description = "enable nix customizations";
    };
  };

  config = lib.mkIf cfg.enable {
    nix.settings.experimental-features = [ "nix-command" "flakes" ];
  };
}
