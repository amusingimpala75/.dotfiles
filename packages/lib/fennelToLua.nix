{
  stdenvNoCC,
  lua54Packages,
}:
drvArgs:
(stdenvNoCC.mkDerivation drvArgs).overrideAttrs (
  _: _: {
    buildInputs = [ lua54Packages.fennel ];
    phases = [ "buildPhase" ];
    buildPhase = ''
      fennel -c $src > $out
    '';
  }
)
