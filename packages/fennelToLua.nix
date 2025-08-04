{
  stdenv,
  fennel,
}:
drvArgs:
(stdenv.mkDerivation drvArgs).overrideAttrs (
  final: prev: {
    buildInputs = [ fennel ];
    phases = [ "buildPhase" ];
    buildPhase = ''
      fennel -c $src > $out
    '';
  }
)
