{ userSettings, ... }:
{
  imports = [ ../direnv ];

  programs.direnv.enableZshIntegration = true;

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
      highlight = "fg=#${userSettings.theme.base03},bold,underline";
    };
  };
}
