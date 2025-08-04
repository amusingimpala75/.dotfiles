{
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.my.ghostty;
  stdenv = pkgs.stdenv;
in
{
  config = lib.mkIf (stdenv.isDarwin && cfg.enable) {
    home.file.".hushlogin".text = "";
  };
}
