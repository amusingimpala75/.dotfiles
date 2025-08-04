{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.wsl;
  enable = "" == (builtins.getEnv "WSL_DISTRO_NAME");
  enabledDefaultOn = desc: (lib.mkEnableOption desc) // { default = false; };
in
{
  options.wsl = {
    username = lib.mkOption {
      type = lib.types.str;
      example = "johndoe28";
      description = "username of the windows user (i.e. C:\Users\<username>)";
    };

    wezterm.enable = enabledDefaultOn "set wezterm config";

    wallpaper.enable = lib.mkEnableOption "set Windows wallpaper";
  };

  config = lib.mkIf enable {
    home.activation.set-wallpaper = lib.mkIf cfg.wallpaper.enable (
      lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        mkdir -p /mnt/c/Users/${cfg.username}/.nix-profile/share
        rm -f /mnt/c/Users/${cfg.username}/.nix-profile/share/wallpaper.png
        cp ${config.rice.wallpaper} /mnt/c/Users/${cfg.username}/.nix-profile/share/wallpaper.png 2>/dev/null
        ${pkgs.wallp}/bin/WallP.exe 'C:\Users\${cfg.username}\.nix-profile\share\wallpaper.png'
      ''
    );

    home.activation.cp-wezterm = lib.mkIf (config.programs.wezterm.enable && cfg.wezterm.enable) (
      lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        # mkdir -p /mnt/c/Users/${cfg.username}/
        rm -f /mnt/c/Users/${cfg.username}/.wezterm.lua
        cat > /mnt/c/Users/${cfg.username}/.wezterm.lua << EOF
        ${config.xdg.configFile."wezterm/wezterm.lua".text}
        EOF

        mkdir -p /mnt/c/Users/${cfg.username}/scoop/apps/wezterm/current/colors
        rm -f /mnt/c/Users/${cfg.username}/scoop/apps/wezterm/current/colors/my-base16.toml
        cat > /mnt/c/Users/${cfg.username}/scoop/apps/wezterm/current/colors/my-base16.toml << EOF
        ${builtins.readFile config.xdg.configFile."wezterm/colors/my-base16.toml".source}
        EOF
      ''
    );
  };
}
