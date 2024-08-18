{ lib, config, pkgs, username, ... }:

let
  emacsTerm = "emacsclient -nw";
  emacsGui = "emacsclient -c";
  emacsPackage = pkgs.emacs;
in
{
  home.packages = with pkgs; [
    emacsPackage
  ];

  launchd.agents.emacs = {
    enable = true;
    config = {
      WorkingDirectory = "/Users/${username}";
      StandardOutPath = "/tmp/emacs-stdout";
      StandardErrorPath = "/tmp/emacs-stderr";
      Program = "${emacsPackage}/bin/emacs";
      ProgramArguments = [ "emacs" "--fg-daemon" ];
      KeepAlive = true;
    };
  };

  home.shellAliases = {
    vim = emacsTerm;
    vi = emacsTerm;
  };

  home.sessionVariables = {
    EDITOR = emacsTerm;
  };

  targets.darwin.defaults."org.gnu.Emacs" = {
    AppleFontSmoothing = 0;
  };
}
