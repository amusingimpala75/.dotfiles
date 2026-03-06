{
  fetchFromGitHub,
  melpaBuild,
  olivetti,
  ...
}:
melpaBuild {
  pname = "page-view";
  version = "0-unstable-2025-12-24";
  src = fetchFromGitHub {
    owner = "bradmont";
    repo = "page-view";
    rev = "dfc361f1f7b503cd45eade6cbe45cc5d73b2ccb9";
    hash = "sha256-oiceeDz3ban3KcSPVzmwnQBqTPJXiGLxg2kEnNPM4tI=";
  };
  packageRequires = [ olivetti ];
  patches = [
    ./footnotes-rename.patch
    ./page-view-rename.patch
  ];
}
