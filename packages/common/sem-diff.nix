{
  lib,
  rustPlatform,
  pkg-config,
  libgit2,
  openssl,
  zlib,
  libssh2,
  fetchFromGitHub,
  ...
}:
rustPlatform.buildRustPackage rec {
  pname = "sem";
  version = "0.3.10";

  src = fetchFromGitHub {
    owner = "Ataraxy-Labs";
    repo = "sem";
    rev = "v${version}";
    hash = "sha256-H/VjtBEXtE9hwBS/uqo9Hp0FQ76kT2XxpB4kGJDZxRs=";
  };

  cargoRoot = "crates";
  cargoHash = "sha256-+bBWrEioPGoUJHykGaMGyLunPM5cfrWDRXan3JDcXPs=";
  buildAndTestSubdir = "crates";

  cargoBuildFlags = [ "-p" "sem-cli" ];
  cargoTestFlags = cargoBuildFlags;

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [
    libgit2
    openssl
    zlib
    libssh2
  ];

  meta = with lib; {
    description = "Semantic diff CLI that reports entity-level changes";
    homepage = "https://github.com/Ataraxy-Labs/sem";
    license = with licenses; [ mit asl20 ];
    mainProgram = "sem";
    platforms = platforms.all;
  };
}
