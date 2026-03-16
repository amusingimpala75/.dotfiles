{
  lib,
  rustPlatform,
  pkg-config,
  openssl,
  fetchFromGitHub,
  ...
}:
rustPlatform.buildRustPackage rec {
  pname = "weave";
  version = "0.2.4";

  src = fetchFromGitHub {
    owner = "Ataraxy-Labs";
    repo = "weave";
    rev = "v${version}";
    hash = "sha256-PVpxP6ilQNatBY9+OnT0XJYJMRIcEW5p2mj0Kmd4uzg=";
  };

  cargoHash = "sha256-ytw15o9Z16P1sX8IvNw7cmwS8T1PEWK4IJ0/2zPm3so=";

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs = [
    openssl
  ];

  cargoBuildFlags = [
    "-p"
    "weave-cli"
    "-p"
    "weave-driver"
  ];

  cargoInstallFlags = cargoBuildFlags;

  doCheck = false;

  meta = with lib; {
    description = "Entity-level semantic merge tool for Git conflicts";
    homepage = "https://github.com/Ataraxy-Labs/weave";
    license = with licenses; [ mit asl20 ];
    mainProgram = "weave";
    platforms = platforms.unix;
  };
}
