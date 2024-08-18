{ lib, config, pkgs, username, ... }:

let
  emacsTerm = "emacsclient -nw";
  emacsGui = "emacsclient -c";
  emacsPackage = pkgs.emacsWithPackagesFromUsePackage {
    package = pkgs.emacs;
    alwaysTangle = true;
    defaultInitFile = true;
    config = ./config.org;
  };
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
      ProgramArguments = [ "${emacsPackage}/bin/emacs" "--fg-daemon" ];
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
