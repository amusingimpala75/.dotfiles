{
  fetchFromGitHub,
  s,
  scala-mode,
  trivialBuild,
  xterm-color,
  ...
}:
trivialBuild {
  pname = "scala-repl-cli";
  version = "git+2026-01-22";
  src = fetchFromGitHub {
    owner = "ag91";
    repo = "scala-cli-repl";
    rev = "a6e91851d8617ab340b5cc8bdbd7b93fd89a2316";
    hash = "sha256-XWdu4rvoubCNZH3v+cfeWLy0IPxElyPQ4AqdrSZkjaM=";
  };
  packageRequires = [
    s
    scala-mode
    xterm-color
  ];
}
