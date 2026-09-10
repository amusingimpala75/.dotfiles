{
  curl,
  fetchurl,
  jq,
  lib,
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
in
symlinkJoin {
  name = "minecraft-music";
  inherit paths;
  update = writeShellApplication {
    name = "update-minecraft-music";
    text = builtins.readFile ./update.sh;
    meta.platforms = lib.platforms.all;
    runtimeInputs = [
      curl
      jq
    ];
  };
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
}
