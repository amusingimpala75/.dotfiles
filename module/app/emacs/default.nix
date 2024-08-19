{ lib, config, pkgs, username, userSettings, ... }:

let
  emacsTerm = "TERM=alacritty-direct emacsclient -nw";
  emacsGui = "emacsclient -c";
  emacsPackage = pkgs.emacsWithPackagesFromUsePackage {
    package = pkgs.emacs;
    alwaysTangle = true;
    defaultInitFile = true;
    config = ./config.org;
    extraEmacsPackages = epkgs: [
      (epkgs.trivialBuild {
        pname = "my-base16-theme";
	version = "0.1.0";
	src = pkgs.writeText "my-base16-theme.el" (with userSettings.theme; ''
	  (require 'base16-theme)

          (defvar my-base16-theme-colors
	    '(:base00 "#${base00}"
	      :base01 "#${base01}"
	      :base02 "#${base02}"
	      :base03 "#${base03}"
	      :base04 "#${base04}"
	      :base05 "#${base05}"
	      :base06 "#${base06}"
	      :base07 "#${base07}"
	      :base08 "#${base08}"
	      :base09 "#${base09}"
	      :base0A "#${base0A}"
	      :base0B "#${base0B}"
	      :base0C "#${base0C}"
	      :base0D "#${base0D}"
	      :base0E "#${base0E}"
	      :base0F "#${base0F}"))

	  (deftheme my-base16)
	  (base16-theme-define 'my-base16 my-base16-theme-colors)
	  (provide-theme 'my-base16)

	  (add-to-list 'custom-theme-load-path (file-name-directory (file-truename load-file-name)))

	  (provide 'my-base16-theme)
	'');
	packageRequires = [ epkgs.base16-theme ];
      })
    ];
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
