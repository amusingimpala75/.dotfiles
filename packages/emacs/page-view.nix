{
  emacs,
  emacsPackagesFor,
  fetchFromGitHub,
  ...
}:
let
  epkgs = emacsPackagesFor emacs;
in
epkgs.trivialBuild {
  pname = "page-view";
  version = "git+2025-12-10";
  src = fetchFromGitHub {
    owner = "bradmont";
    repo = "page-view";
    rev = "f74d46c63c229911655e4a3df49d210db70f8261";
    hash = "sha256-Z/Oeq1yd9D2aI5e3B3OVOHW3Lcu4ECSxv19QiQdIR0Q=";
  };
  packageRequires = [ epkgs.olivetti ];
  patches = [ ./page-view-rename.patch ];
}
