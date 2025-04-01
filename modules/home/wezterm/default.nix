{ config, lib, ... }:
let
  cfg = config.my.wezterm;
in {
  options.my.wezterm.enable = lib.mkEnableOption "my wezterm config";

  config = lib.mkIf cfg.enable {
    programs.wezterm = {
      enable = true;
      extraConfig = builtins.readFile ./config.lua;
    };
  };
}
