{
  fetchFromGitHub,
  gcc,
  lib,
  luaPackages,
  readline,
  ...
}:
luaPackages.buildLuaPackage {
  pname = "rift-lua";
  version = "0-unstable-2026-02-20";

  src = fetchFromGitHub {
    owner = "acsandmann";
    repo = "rift.lua";
    rev = "4ef184ff186431fa2c6e6f8d43938588c30b0885";
    hash = "sha256-nrF+QZAENHULrpFmB2OJ4aw4G1FeaeV5xvAst4Pb5QY=";
  };

  nativeBuildInputs = [ gcc ];

  buildInputs = [ readline ];

  preBuild = ''
    tar xvf ${luaPackages.lua.src}
  '';

  makeFlags = [
    "INSTALL_DIR=$(out)/lib/lua/${luaPackages.lua.luaversion}"
    "LUA_DIR=lua-${luaPackages.lua.version}"
  ];

  meta = {
    description = "Lua API for Rift WM";
    homepage = "https://github.com/acsandmann/rift.lua";
    license = lib.licenses.apsl20;
    platforms = lib.platforms.darwin;
  };
}
