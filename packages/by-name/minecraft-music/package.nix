{
  curl,
  fetchurl,
  jq,
  lib,
  linkFarm,
  nix,
  nix-update,
  writeShellApplication,
}:
let
  paths = map (
    entry:
    fetchurl {
      name = entry.filename;
      inherit (entry) url;
      hash = entry.sha256;
    }
  ) (builtins.fromJSON (builtins.readFile ./index.json));
  # The next update records the Mojang snapshot used to generate index.json.
  version = "26.4-snapshot-7";
  links = map (track: {
    inherit (track) name;
    path = track;
  });
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
(linkFarm "minecraft-music-${version}" (links paths)).overrideAttrs (_: {
  pname = "minecraft-music";
  inherit version;
  passthru.update = update;
  passthru.updateScript = lib.getExe update;
  passthru.albums = builtins.mapAttrs (
    name: value:
    let
      tracks = map (entry: {
        name = lib.removeSuffix ".ogg" entry;
        value = lib.findFirst (x: x.name == entry) null paths;
      }) value;
    in
    (linkFarm name (links (map (t: t.value) tracks))).overrideAttrs (_: {
      passthru.tracks = builtins.listToAttrs tracks;
    })
  ) albums;
  meta.platforms = lib.platforms.all;
})
