{ ... }:
{
  imports = [ ../direnv ];

  programs.direnv.enableZshIntegration = true;

  programs.zsh = {
    enable = true;
    dotDir = ".config/zsh";
    initExtra = ''
      function precmd_nix_shell {
        if echo "$PATH" | grep -q "/nix/store";
        then
          if [[ -z "$IN_NIX_SHELL" ]]
          then
            _PROMPT_NIX_SHELL=" (shell)"
          else
            _PROMPT_NIX_SHELL=" (dev)"
          fi
        else
          _PROMPT_NIX_SHELL=""
        fi
      }
      precmd_functions=(precmd_nix_shell)
      setopt prompt_subst
      export PROMPT='%n@%U%m%u''${_PROMPT_NIX_SHELL}> '
      export RPROMPT="%F{green}%~%f"
    '';
    autosuggestion = {
      enable = true;
      highlight = "bg=cyan,bold,underline";
    };
  };
}
