{ config, lib, pkgs, ... }:
let
  cfg = config.my.emacs;
  stdenv = pkgs.stdenv;
in {
  config = lib.mkIf (cfg.enable && stdenv.isDarwin) {
    targets.darwin.defaults."org.gnu.Emacs" = {
      AppleFontSmoothing = 0;
    };

    launchd.agents.emacs = lib.mkIf cfg.service {
      enable = true;
      config = {
        StandardOutPath = "/tmp/emacs-stdout";
        StandardErrorPath = "/tmp/emacs-stderr";
        Program = "${cfg.package}/bin/emacs";
        ProgramArguments = [ "${cfg.package}/bin/emacs" "--fg-daemon" ];
        KeepAlive = true;
      };
    };
  };
}
