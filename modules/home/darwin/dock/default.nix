{
  config,
  lib,
  pkgs,
  ...
}:
let
  dockutil = "${pkgs.dockutil}/bin/dockutil";
  add-dock-item =
    item: "${dockutil} --add \"${item}\"" + (if item == "" then "--type spacer" else "");
in
{
  options.my.darwin.dock.items = lib.mkOption {
    type = lib.types.nullOr (lib.types.listOf lib.types.str);
    default = null;
    description = "items to add to dock";
  };

  config = {
    home.activation.set-dock =
    lib.mkIf (pkgs.stdenv.isDarwin && (config.my.darwin.dock.items != null))
      (
        lib.hm.dag.entryAfter [ "writeBoundary" ] (
          ''
            ${dockutil} --remove all
          ''
          + (lib.concatStringsSep "\n" (map add-dock-item config.my.darwin.dock.items))
        )
      );
    targets.darwin = lib.mkIf pkgs.stdenv.isDarwin {
      copyApps.enable = true;
      linkApps.enable = false;
    };
  };
}
