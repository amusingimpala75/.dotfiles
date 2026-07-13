{
  flake.modules.homeManager.emacs =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    {
      services.emacs = {
        enable = true;
        package = pkgs.custom-emacs.override {
          font-family-fixed = "Maple Mono NF CN";
          font-family-variable = "Liberation Serif";
          opacity = 0.9;
          theme-package = epkgs: epkgs.ef-themes;
          theme-file-name = "ef-themes";
          theme-name = "ef-elea-dark";
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

      sops = {
        secrets =
          (lib.genAttrs
            [
              "emacs-feeds.el"
              "emacs-radio-channels.el"
              "emacs-signel-number.el"
              "emacs-emails.el"
            ]
            (file: {
              format = "binary";
              sopsFile = ../../../secrets/${file};
              path = "%r/${file}";
            })
          )
          // {
            "nixos_discourse_password" = { };
            "libera_chat_password" = { };
          };

        templates = {
          "nixos_discourse.authinfo".content = ''
            machine discourse.nixos.org login AmusingImpala75 password ${
              config.sops.placeholder."nixos_discourse_password"
            }
          '';

          "libera-chat.authinfo".content = ''
            machine irc.libera.chat login amusingimpala75 password ${
              config.sops.placeholder."libera_chat_password"
            }
          '';
        };
      };

      home = {
        packages = [
          pkgs.noto-fonts-cjk-sans
          pkgs.maple-mono.NF-CN-unhinted
          pkgs.liberation_ttf
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
