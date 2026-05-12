let
  darwin =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    {
      config = lib.mkIf pkgs.stdenv.isDarwin {
        home.activation.set-wallpaper = lib.hm.dag.entryBetween [ "restart-dock" ] [ "writeBoundary" ] ''
          ${lib.getExe pkgs.desktoppr} ${config.rice.wallpaper}
        '';
      };
    };
  wsl =
    {
      config,
      lib,
      pkgs,
      options,
      ...
    }:
    {
      config = lib.optionalAttrs (options ? wsl) {
        wsl.userFile.".nix-profile/share/wallpaper.png".source = config.rice.wallpaper;
        home.activation.set-wallpaper = lib.hm.dag.entryAfter [ "wslUserFiles" ] ''
          ${lib.getExe pkgs.wallp} 'C:\Users\${config.wsl.username}\.nix-profile\share\wallpaper.png'
        '';
      };
    };
in
{
  flake.modules.homeManager.wallpaper = {
    imports = [
      darwin
      wsl
    ];
  };
}
