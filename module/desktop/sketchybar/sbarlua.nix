# Courtesy of r17x at https://github.com/r17x/universe
{
  lua54Packages,
  gcc,
  darwin,
  fetchFromGitHub,
  readline,
  ...
}:

let
  inherit (lua54Packages) buildLuaPackage;
in

buildLuaPackage {
  name = "sbarlua";
  pname = "sbarlua";
  version = "0.0.0";

  src = fetchFromGitHub {
    owner = "FelixKratz";
    repo = "SbarLua";
    rev = "437bd2031da38ccda75827cb7548e7baa4aa9978";
    sha256 = "sha256-F0UfNxHM389GhiPQ6/GFbeKQq5EvpiqQdvyf7ygzkPg=";
  };

  buildInputs = [
    gcc
    darwin.apple_sdk.frameworks.CoreFoundation
    readline
  ];

  installPhase = # bash
    ''
      mkdir -p $out/lib
      cp bin/sketchybar.so $out/lib
    '';
}
