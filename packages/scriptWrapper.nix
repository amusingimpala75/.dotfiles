{
  makeWrapper,
  symlinkJoin,
  writeScriptBin,
  ...
}:
name: deps:
let
  script = (writeScriptBin name (builtins.readFile ./${name}.sh)).overrideAttrs (old: {
    buildCommand = "${old.buildCommand}\n patchShebangs $out";
  });
in
symlinkJoin {
  pname = name;
  version = "0.1.0";
  paths = [ script ] ++ deps;
  buildInputs = [ makeWrapper ];
  postBuild = "wrapProgram $out/bin/${name} --prefix PATH : $out/bin";
}
