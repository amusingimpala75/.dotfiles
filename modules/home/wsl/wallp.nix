{
  config,
  lib,
  pkgs,
  ...
}:
{
  options.wsl.wallp.enable = lib.mkEnableOption "wallp wallpaper sync";

  config = lib.mkIf config.wsl.wallp.enable {
    wsl.userFile.".nix-profile/share/wallpaper.png".source = config.rice.wallpaper;
    home.activation.setWallpaper =
      lib.hm.dag.entryAfter [ "writeBoundary" ".nix-profile/share/wallpaper.png" ]
        ''
          ${pkgs.wallp}/bin/WallP.exe 'C:\Users\${config.wsl.username}\.nix-profile\share\wallpaper.png'
        '';
  };
}
