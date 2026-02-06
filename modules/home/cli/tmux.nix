{
  config,
  lib,
  ...
}:
{
  options.my.tmux.enable = lib.mkEnableOption "my tmux configuration";

  config = lib.mkIf config.my.tmux.enable {
    programs.tmux = {
      aggressiveResize = true;
      clock24 = true;
      enable = true;
      extraConfig = ''
        set -g status off
      '';
      historyLimit = 50000;
      newSession = true;
      secureSocket = true;
      shortcut = "q";
      terminal = "xterm-direct";
    };
  };
}
