{
  fetchFromGitHub,
  gcc,
  lib,
  lua55Packages,
  readline,
  ...
}:
lua55Packages.buildLuaPackage {
  pname = "rift-lua";
  version = "0-unstable-2026-09-06";

  src = fetchFromGitHub {
    owner = "acsandmann";
    repo = "rift.lua";
    rev = "c5c087daf5da63e9b29e6c448ccabe364b7e13af";
    hash = "sha256-QFO3ed2zlmwSVfdvXxnxn80CNWiclOXW6V8OzgmogF4=";
  };

  nativeBuildInputs = [ gcc ];

  buildInputs = [ readline ];

  preBuild = ''
    tar xvf ${lua55Packages.lua.src}
  '';

  makeFlags = [
    "INSTALL_DIR=$(out)/lib/lua/${lua55Packages.lua.luaversion}"
    "LUA_DIR=lua-${lua55Packages.lua.version}"
  ];

  meta = {
    description = "Lua API for Rift WM";
    homepage = "https://github.com/acsandmann/rift.lua";
    license = lib.licenses.apsl20;
    platforms = lib.platforms.darwin;
  };
}
