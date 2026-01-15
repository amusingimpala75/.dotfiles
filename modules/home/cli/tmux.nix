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
      historyLimit = 50000;
      mouse = true;
      newSession = true;
      secureSocket = true;
      terminal = "screen-256color";
    };
  };
}
