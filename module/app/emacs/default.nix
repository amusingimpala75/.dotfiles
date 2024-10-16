{ pkgs, username, userSettings, ... }:

let
  emacsTerm = "TERM=alacritty-direct emacsclient -nw";
  emacsGui = "emacsclient -c";
  emacsPackage = (import ./package.nix) pkgs userSettings;
in
{
  home.packages = [
    emacsPackage
    pkgs.nixd
    pkgs.nixfmt-rfc-style
  ];

  home.shellAliases = {
    vim = emacsTerm;
    vi = emacsTerm;
    gvim = emacsGui;
    gvi = emacsGui;
  };

  services.emacs = pkgs.lib.mkIf pkgs.stdenv.isLinux {
    defaultEditor = true;
    enable = true;
    package = emacsPackage;

    client.enable = true;
    client.arguments = [ "-c" ];
  };

  home.sessionVariables = {
    EDITOR = pkgs.lib.mkIf pkgs.stdenv.isDarwin emacsTerm;
  };

  # I honestly have no idea why targets.darwin.<thing> has issues while launchd agents don't when in Linux.
  targets.darwin.defaults."org.gnu.Emacs" = pkgs.lib.mkIf pkgs.stdenv.isDarwin {
    AppleFontSmoothing = 0;
  };

  launchd.agents.emacs = {
    enable = true;
    config = {
      StandardOutPath = "/tmp/emacs-stdout";
      StandardErrorPath = "/tmp/emacs-stderr";
      Program = "${emacsPackage}/bin/emacs";
      ProgramArguments = [ "${emacsPackage}/bin/emacs" "--fg-daemon" ];
      KeepAlive = true;
    };
  };
}
