{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.my.emacs;
  rice = config.rice;
in
{
  imports = [
    ./darwin.nix
    ./nixos.nix
  ];
  options.my.emacs = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      example = true;
      description = "Enable emacs package";
    };
    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.my.emacs.override {
        font-size = rice.font.size;
        font-family-fixed = rice.font.family.fixed-pitch;
        font-family-variable = rice.font.family.variable-pitch;
        opacity = rice.opacity;
        inherit (rice.emacs) theme-package theme-file-name theme-name;
        emacs = pkgs.emacs-git.override {
          withXwidgets = (builtins.getEnv "WSL_DISTRO_NAME") != "";
        };
      };
      example = pkgs.emacs;
      description = "package for emacs to use";
    };
    service = lib.mkOption {
      type = lib.types.bool;
      default = true;
      example = false;
      description = "whether to enable emacs daemon";
    };
    gui-command = lib.mkOption {
      type = lib.types.str;
      default = "emacsclient -c";
      example = "emacs";
      description = "command to launch emacs as gui";
    };
    term-command = lib.mkOption {
      type = lib.types.str;
      default = "emacsclient -nw";
      example = "emacs -nw";
      description = "command to launch emacs in term";
    };
    vi-aliases = lib.mkOption {
      type = lib.types.bool;
      default = true; # *chuckles maniacally*
      example = false;
      description = "override vim/vi aliases as emacs";
    };
    editor = lib.mkOption {
      type = lib.types.bool;
      default = true;
      example = false;
      description = "emacs as default editor";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [
      cfg.package
    ];

    home.shellAliases = lib.mkIf cfg.vi-aliases {
      vim = cfg.term-command;
      vi = cfg.term-command;
      gvim = cfg.gui-command;
      gvi = cfg.gui-command;
    };

    home.sessionVariables = lib.optionalAttrs cfg.editor {
      EDITOR = cfg.term-command;
    };
  };
}
