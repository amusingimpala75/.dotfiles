{
  fetchFromGitHub,
  rustPlatform,
  ...
}:
rustPlatform.buildRustPackage {
  name = "rift";
  version = "0.4.0";

  src = fetchFromGitHub {
    owner = "acsandmann";
    repo = "rift";
    rev = "v0.4.0";
    hash = "sha256-3TKhoLJE+GtTfcnskH7yUBamCV+G5xXzy1n15mNWDzk=";
  };

  cargoBuildFlags = [
    "--bins"
  ];

  cargoHash = "sha256-2KMEjAGWxMzcY9yE5v9SmAspA4tDJtNwS0GlEm4opKc=";

  doCheck = false;

  meta.mainProgram = "rift";
}
