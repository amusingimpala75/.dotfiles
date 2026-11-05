{
  curl,
  fetchurl,
  jq,
  lib,
  nix,
  nix-update,
  runCommand,
  symlinkJoin,
  writeShellApplication,
}:
let
  paths = map (
    entry:
    runCommand "${lib.removeSuffix ".ogg" entry.filename}" { } ''
      mkdir $out
      cp ${
        fetchurl {
          inherit (entry) url;
          hash = entry.sha256;
        }
      } $out/${entry.filename}
    ''
  ) (builtins.fromJSON (builtins.readFile ./index.json));
  albums = builtins.fromJSON (builtins.readFile ./albums.json);
  update = writeShellApplication {
    name = "update-minecraft-music";
    text = ''
      output=${
        lib.escapeShellArg (
          let
            path = toString ./index.json;
            storePrefix = "${builtins.storeDir}/";
          in
          if lib.hasPrefix storePrefix path then
            lib.concatStringsSep "/" (lib.drop 1 (lib.splitString "/" (lib.removePrefix storePrefix path)))
          else
            path
        )
      }
    ''
    + builtins.readFile ./update.sh;
    meta.platforms = lib.platforms.all;
    runtimeInputs = [
      curl
      jq
      nix
      nix-update
    ];
  };
in
(symlinkJoin {
  pname = "minecraft-music";
  # The next update records the Mojang snapshot used to generate index.json.
  version = "26.4-snapshot-7";
  inherit paths;
  passthru.update = update;
  passthru.updateScript = lib.getExe update;
  passthru.albums = builtins.mapAttrs (
    name: value:
    let
      tracks = map (entry: {
        name = lib.removeSuffix ".ogg" entry;
        value = lib.findFirst (x: x.name == (lib.removeSuffix ".ogg" entry)) null paths;
      }) value;
    in
    symlinkJoin {
      inherit name;
      paths = map (t: t.value) tracks;
      passthru.tracks = builtins.listToAttrs tracks;
    }
  ) albums;
}).overrideAttrs
  (_: {
    meta.platforms = lib.platforms.all;
  })
