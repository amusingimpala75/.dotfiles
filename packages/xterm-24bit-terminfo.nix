{ ncurses5, stdenv, ... }:
stdenv.mkDerivation {
  name = "xterm-24bit-terminfo";

  src = ./xterm-24bit.terminfo;

  buildPhase = ''
    mkdir -p $out/share/terminfo # :TODO: fix
    tic -x -o $out/share/terminfo $src
  '';

  out = [ "terminfo" ];

  buildInputs = [ ncurses5 ];

  phases = [ "buildPhase" ];
}
