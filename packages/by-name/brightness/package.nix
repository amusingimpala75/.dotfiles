{
  apple-sdk,
  fetchFromGitHub,
  lib,
  stdenv,
  nix-update-script,
  ...
}:
stdenv.mkDerivation {
  pname = "brightness";
  version = "0-unstable-2021-02-28";

  src = fetchFromGitHub {
    owner = "nriley";
    repo = "brightness";
    rev = "bbbe5a26cf8fc0496801c1af84cee9ba53f27a51";
    hash = "sha256-FCkCHs0h1uf/h5rUr6FBftnoEFLMWnEUCG6NWuzUTso=";
  };

  makeFlags = [ "prefix=$(out)" ];

  buildInputs = [ apple-sdk ];

  passthru.updateScript = nix-update-script {
    attrPath = "brightness";
    extraArgs = [
      "--flake"
      "--version=branch"
    ];
  };

  meta = {
    description = "CLI application to set the screen brightness";
    license = lib.licenses.bsd2;
    platforms = lib.platforms.darwin;
    mainProgram = "brightness";
  };
}
