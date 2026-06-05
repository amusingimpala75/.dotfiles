{
  flake.modules.homeManager.emacs =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      inherit (config) rice;
    in
    {
      services.emacs = {
        enable = true;
        package = pkgs.custom-emacs.override {
          font-size = rice.font.size;
          font-family-fixed = rice.font.family.fixed-pitch;
          font-family-variable = rice.font.family.variable-pitch;
          inherit (rice) opacity;
          inherit (rice.emacs) theme-package theme-file-name theme-name;
          emacs = pkgs.emacs-git;
        };

        client.enable = true;
        client.arguments = [ "-c" ];
      };

      fonts.fontconfig.enable = true;

      targets.darwin.defaults."org.gnu.Emacs".AppleFontSmoothing = lib.mkIf pkgs.stdenv.isDarwin 0;

      programs.emacs = {
        enable = true;
        package = config.services.emacs.package;
      };

      home = {
        packages = [
          pkgs.noto-fonts-cjk-sans
        ];

        shellAliases = {
          vim = config.home.sessionVariables.EDITOR;
          vi = config.home.sessionVariables.EDITOR;
          gvim = config.home.sessionVariables.VISUAL;
          gvi = config.home.sessionVariables.VISUAL;
        };

        sessionVariables.EDITOR = "emacsclient -nw";
        sessionVariables.VISUAL = "emacsclient -c";

        file.".emacs.d/snippets".source =
          config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.dotfiles/modules/flake/emacs/snippets";
      };
    };
}
