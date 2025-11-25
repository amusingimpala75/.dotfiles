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
  pname = "zone-matrix";
  version = "git+2023-12-21";
  src = fetchFromGitHub {
    owner = "twitchy-ears";
    repo = "zone-matrix";
    rev = "508e2fa6f1d9b69752c1629f76349bdd102f40d1";
    hash = "sha256-uQQviKTvZfWcdovfxy/jF60onFEJYcp98nDrtDt2CGA=";
  };
}
