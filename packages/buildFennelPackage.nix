{
  lua54Packages,
  stdenv,
  fennel,
  ...
}:
drvArgs:
lua54Packages.toLuaModule (
  (stdenv.mkDerivation drvArgs).overrideAttrs (
    final: prev: {
      buildInputs = [ fennel ];
      phases = [ "buildPhase" ];
      buildPhase = ''
        for file in $( find $src -type f -name "*.fnl" ); do

        relpath=''${file#$src}
        relpath=''${relpath%.fnl}
        outpath=$out/share/lua/${lua54Packages.lua.luaversion}/$relpath.lua

        mkdir -p $(dirname $outpath)
        fennel -c $file > $outpath

        done
      '';
    }
  )
)
