{
  fzf,
  makeWrapper,
  symlinkJoin,
  writeScriptBin,
  ...
}:
let
  name = "launcher";
  script = (writeScriptBin name (builtins.readFile ./${name}.sh)).overrideAttrs(old: {
    buildCommand = "${old.buildCommand}\n patchShebangs $out";
  });
in symlinkJoin {
  inherit name;
  paths = [ script fzf ];
  buildInputs = [ makeWrapper ];
  postBuild = "wrapProgram $out/bin/${name} --prefix PATH : $out/bin";
}
