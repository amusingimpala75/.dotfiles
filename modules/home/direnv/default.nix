{ lib, config, inputs, ... }:
let
  cfg = config.my.direnv;
in
{
  imports = [ inputs.direnv-instant.homeModules.direnv-instant ];
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
      enableBashIntegration = false;
      enableZshIntegration = false;
      nix-direnv.enable = true;
      silent = true;
    };
    programs.direnv-instant.enable = true;
  };
}
