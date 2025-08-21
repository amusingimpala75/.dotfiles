{
  emacs,
  emacsPackagesFor,
  fetchFromGitHub,
  ...
}:
let
  epkgs = emacsPackagesFor emacs;
in epkgs.trivialBuild {
  pname = "nnnrss";
  version = "git+2025-3-9";
  src = fetchFromGitHub {
    owner = "jjbarr";
    repo = "nnnrss";
    rev = "941f89277fabd44dd03eb654e183553c86ba35c8";
    hash = "sha256-rm5bquIsdY8Nj7l8B2nxu7tpNszNlN1zwjBA09yvpCs=";
  };
}
