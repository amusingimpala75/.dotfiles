{
  config,
  lib,
  pkgs,
  ...
}:
let
  dockutil = lib.getExe pkgs.dockutil;
  add-dock-item =
    item: "${dockutil} --add \"${item}\"" + (if item == "" then "--type spacer" else "") + " --no-restart";
in
{
  options.my.darwin.dock.items = lib.mkOption {
    type = lib.types.nullOr (lib.types.listOf lib.types.str);
    default = null;
    description = "items to add to dock";
  };

  config = lib.mkIf pkgs.stdenv.isDarwin {
    home.activation = {
      restart-dock = lib.hm.dag.entryAfter [ "setDarwinDefaults" ] ''
        /usr/bin/killall Dock
      '';
      set-dock =
        lib.mkIf (config.my.darwin.dock.items != null)
          (
            lib.hm.dag.entryBetween [ "restart-dock" ] [ "writeBoundary" ] (
              ''
              ${dockutil} --remove all
            ''
              + (lib.concatStringsSep "\n" (map add-dock-item config.my.darwin.dock.items))
            )
          );
    };
    targets.darwin = {
      copyApps.enable = true;
      linkApps.enable = false;
    };
  };
}
