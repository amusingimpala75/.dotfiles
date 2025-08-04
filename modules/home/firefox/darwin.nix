{
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.my.firefox;
in
{
  options.my.firefox.default = lib.mkOption {
    type = lib.types.bool;
    default = cfg.enable;
    example = true;
    description = "Make firefox the default browser on macOS";
  };

  config = lib.mkIf (pkgs.stdenv.isDarwin && cfg.enable) {
    home.activation.default-browser = lib.mkIf cfg.default (
      lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        ${pkgs.defaultbrowser}/bin/defaultbrowser firefox
      ''
    );
  };
}
