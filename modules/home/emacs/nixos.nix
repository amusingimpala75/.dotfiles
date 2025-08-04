{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.my.emacs;
  stdenv = pkgs.stdenv;
in
{
  config = lib.mkIf (cfg.enable && stdenv.isLinux) {
    services.emacs = lib.mkIf cfg.service {
      enable = true;
      package = cfg.package;

      client.enable = true;
      client.arguments = [ "-c" ];
    };

    fonts.fontconfig.enable = true;
    home.packages = [ pkgs.noto-fonts-cjk-sans ];
  };
}
