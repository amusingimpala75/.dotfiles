{
  emacs,
  emacsPackagesFor,
  fetchFromGitHub,
  ...
}:
let
  epkgs = emacsPackagesFor emacs;
in epkgs.trivialBuild {
  pname = "combobulate";
  version = "git+2025-6-20";
  src = fetchFromGitHub {
    owner = "mickeynp";
    repo = "combobulate";
    rev = "17c71802eed2df1a6b25199784806da6763fb90c";
    hash = "sha256-m+06WLfHkdlMkLzP+fah3YN3rHG0H8t/iWEDSrct25E=";
  };
}
