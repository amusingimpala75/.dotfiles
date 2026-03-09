{
  stdenv,
  lua54Packages,
}:
drvArgs:
(stdenv.mkDerivation drvArgs).overrideAttrs (
  _: _: {
    buildInputs = [ lua54Packages.fennel ];
    phases = [ "buildPhase" ];
    buildPhase = ''
      fennel -c $src > $out
    '';
  }
)
