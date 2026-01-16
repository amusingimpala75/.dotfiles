{
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.my.zsh;
in
{
  options.my.zsh = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      example = true;
      description = "Enable zsh configuration";
    };
    inline-suggestion-color = lib.mkOption {
      type = lib.types.str;
      default = "${config.rice.theme.base03}";
      example = "808080";
      description = "Set color of the inline suggestions";
    };
  };

  config = lib.mkIf cfg.enable {
    programs.direnv.enableZshIntegration = lib.mkIf config.my.direnv.enable true;

    programs.zsh = {
      enable = true;
      dotDir = "${config.home.homeDirectory}/.config/zsh";
      autosuggestion = {
        enable = true;
        highlight = "fg=#${cfg.inline-suggestion-color},bold,underline";
      };
      defaultKeymap = "emacs";
      initContent = lib.mkMerge [
        (lib.mkBefore ''
          if [ -z "$TMUX" ]
          then
            tmux
            exit
          fi
        '')
        (lib.mkOrder 1000 ''
          source ${pkgs.git}/share/git/contrib/completion/git-prompt.sh
          function __my_zsh_set_direnv_status {
            if direnv status | grep -q "Loaded RC";
            then
              __my_zsh_direnv_status=direnv
            elif echo "''${PATH%:*}" | grep -q "/nix/store"; # Change PATH%:* because Ghostty will add its entry onto the path, as the last item
            then
              if [ -z "$IN_NIX_SHELL" ]
              then
                __my_zsh_direnv_status=shell
              else
                __my_zsh_direnv_status=dev
              fi
            else
              __my_zsh_direnv_status=""
            fi
          }
          function precmd_prompt {
            _PROMPT_ENV=$(__git_ps1 "%s")
            __my_zsh_set_direnv_status
            if [ ! -z "$_PROMPT_ENV" ] && [ ! -z "$__my_zsh_direnv_status" ]
            then
              _PROMPT_ENV+="|"
            fi
            _PROMPT_ENV+=$__my_zsh_direnv_status
            if [ ! -z "$_PROMPT_ENV" ]
            then
              _PROMPT_ENV=" ($_PROMPT_ENV)"
            fi
          }
          add-zsh-hook precmd precmd_prompt
          setopt prompt_subst
          export PROMPT='%n@%U%m%u''${_PROMPT_ENV}> '
          export RPROMPT="%F{green}%~%f"

          [ -n "$EAT_SHELL_INTEGRATION_DIR" ] && \
            source "$EAT_SHELL_INTEGRATION_DIR/zsh"

          ${pkgs.bible.asv}/bin/asv random
        '')
      ];
    };
  };
}
