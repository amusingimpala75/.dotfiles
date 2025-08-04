{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.my.zsh;
in
{
  options.my.zsh = {
    enable = lib.mkEnableOption "my zsh configuration";
    default = lib.mkOption {
      type = lib.types.bool;
      default = true;
      example = false;
      description = "zsh as default shell";
    };
  };

  config = lib.mkIf cfg.enable {
    users.defaultUserShell = pkgs.zsh;
    programs.zsh.enable = true;
  };
}
