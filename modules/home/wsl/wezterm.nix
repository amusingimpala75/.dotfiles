{
  config,
  lib,
  ...
}:
{
  options.wsl.wezterm.enable = (lib.mkEnableOption "set wezterm config") // {
    default = true;
  };

  config.wsl.userFile = lib.mkIf (config.programs.wezterm.enable && config.wsl.enable) {
    ".wezterm.lua".text = config.xdg.configFile."wezterm/wezterm.lua".text;
    "scoop/apps/wezterm/current/colors/my-base16.toml".source =
      config.xdg.configFile."wezterm/colors/my-base16.toml".source;
  };
}
