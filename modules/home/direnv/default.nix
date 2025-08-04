{ lib, config, ... }:
let
  cfg = config.my.direnv;
in
{
  options.my.direnv = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      example = true;
      description = "enable direnv integration";
    };
  };
  config = lib.mkIf cfg.enable {
    programs.direnv = {
      enable = true;
      nix-direnv.enable = true;
      silent = true;
    };
  };
}
