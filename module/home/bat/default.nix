{ config, lib, ... }:
let
  cfg = config.my.bat;
in {
  options.my.bat = {
    enable = lib.mkEnableOption "my bat configuration";
  };

  config = lib.mkIf cfg.enable {
    programs.bat = {
      enable = true;
      config.theme = "base16";
    };
  };
}
