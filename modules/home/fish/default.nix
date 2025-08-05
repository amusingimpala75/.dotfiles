{
  lib,
  config,
  ...
}:
let
  cfg = config.my.fish;
in
{
  options.my.fish = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      example = true;
      description = "Enable fish configuration";
    };
  };

  config = lib.mkIf cfg.enable {
    home.shell.enableFishIntegration = true;

    programs.fish = {
      enable = true;
      loginShellInit = ''
        set fish_greeting
      '';
      # dotDir = ".config/zsh";
      # autosuggestion = {
      #   enable = true;
      #   highlight = "fg=#${cfg.inline-suggestion-color},bold,underline";
      # };
      # defaultKeymap = "emacs";
      # initContent = ''
      #           function precmd_prompt {
      #           if direnv status | grep -q "Loaded RC";
      #           then
      #           _PROMPT_ENV=" (direnv)";
      #           elif echo "$PATH" | grep -q "/nix/store";
      #           then
      #           if [[ -z "$IN_NIX_SHELL" ]]
      #           then
      #           _PROMPT_ENV=" (shell)"
      #           else
      #           _PROMPT_ENV=" (dev)"
      #           fi
      #           else
      #           _PROMPT_ENV=""
      #           fi
      #           }
      #           add-zsh-hook precmd precmd_prompt
      #           setopt prompt_subst
      #           export PROMPT='%n@%U%m%u''${_PROMPT_ENV}> '
      #           export RPROMPT="%F{green}%~%f"

      #   n        ${pkgs.bible.asv}/bin/asv random
      # '';
    };
  };
}
