{
  apple-sdk,
  fetchFromGitHub,
  lib,
  stdenv,
  ...
}:
stdenv.mkDerivation {
  pname = "brightness";
  version = "git+02-28-2021";

  src = fetchFromGitHub {
    owner = "nriley";
    repo = "brightness";
    rev = "bbbe5a26cf8fc0496801c1af84cee9ba53f27a51";
    hash = "sha256-FCkCHs0h1uf/h5rUr6FBftnoEFLMWnEUCG6NWuzUTso=";
  };

  makeFlags = [ "prefix=$(out)" ];

  buildInputs = [ apple-sdk ];

  meta = {
    platforms = lib.platforms.darwin;
  };
}
