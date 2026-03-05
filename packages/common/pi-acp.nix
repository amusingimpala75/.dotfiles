{
  buildNpmPackage,
  fetchFromGitHub,
  ...
}:
buildNpmPackage rec {
  pname = "pi-acp";
  version = "0.0.21";
  src = fetchFromGitHub {
    owner = "svkozak";
    repo = "pi-acp";
    rev = "v${version}";
    hash = "sha256-QlxFYS9As2EPL6Agq0b4wMbz9hJdJLC3s+/4j4IJKeE=";
  };
  npmDepsHash = "sha256-kjgpycJaCCAu5agB+/qeVv5ZyctJkNwPrnw2hb6pxsc=";
  meta = {
    description = "ACP support for Pi coding agent";
    mainProgram = "pi-acp";
  };
}
