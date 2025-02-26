{ ... }:
{
  programs.zsh = {
    enable = true;
    dotDir = ".config/zsh";
    initExtra = ''
      function precmd {
      if [[ -z "$IN_NIX_SHELL" ]]
      then
      _PROMPT_NIX_SHELL="";
      else
      _PROMPT_NIX_SHELL=" (dev)";
      fi
      }
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
