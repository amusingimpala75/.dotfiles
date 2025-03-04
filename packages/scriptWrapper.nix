{
  makeWrapper,
  symlinkJoin,
  writeScriptBin,
  ...
}:
name: deps:
let
  script = (writeScriptBin name (builtins.readFile ./${name}.sh)).overrideAttrs(old: {
    buildCommand = "${old.buildCommand}\n patchShebangs $out";
  });
in
symlinkJoin {
  inherit name;
  paths = [ script ] ++ deps;
  buildInputs = [ makeWrapper ];
  postbuild = "wrapProgram $out/bin/${name} --prefix PATH : $out/bin";
}
