{
  makeWrapper,
  symlinkJoin,
  writeScriptBin,

  lib,
  ...
}:
{
  path,
  name ?
    path
    # Strip leading directories
    |> baseNameOf
    # Remove suffix
    |> lib.removeSuffix ".sh",
  deps ? [ ],
  extraMeta ? { },
}:
let
  script =
    path
    |> builtins.readFile
    |> writeScriptBin name
    |> (
      drv:
      drv.overrideAttrs (old: {
        buildCommand = ''
          ${old.buildCommand}
          patchShebangs $out
        '';
      })
    );
in
symlinkJoin {
  pname = name;
  version = "0.1.0";
  paths = [ script ] ++ deps;
  buildInputs = [ makeWrapper ];
  postBuild = "wrapProgram $out/bin/${name} --prefix PATH : $out/bin";
  meta = {
    mainProgram = name;
    description = "wrapped shell script";
  }
  // extraMeta;
}
