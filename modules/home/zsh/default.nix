{ lib, config, ... }:
let
  cfg = config.my.zsh;
in {
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
      dotDir = ".config/zsh";
      initExtra = ''
        function precmd_prompt {
        if direnv status | grep -q "Loaded RC";
        then
        _PROMPT_ENV=" (direnv)";
        elif echo "$PATH" | grep -q "/nix/store";
        then
        if [[ -z "$IN_NIX_SHELL" ]]
        then
        _PROMPT_ENV=" (shell)"
        else
        _PROMPT_ENV=" (dev)"
        fi
        else
        _PROMPT_ENV=""
        fi
        }
        add-zsh-hook precmd precmd_prompt
        setopt prompt_subst
        export PROMPT='%n@%U%m%u''${_PROMPT_ENV}> '
        export RPROMPT="%F{green}%~%f"
      '';
      autosuggestion = {
        enable = true;
        highlight = "fg=#${cfg.inline-suggestion-color},bold,underline";
      };
      defaultKeymap = "emacs";
    };
  };
}
