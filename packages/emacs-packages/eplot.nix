{
  fetchFromGitHub,
  melpaBuild,
  pcsv,
  ...
}:
melpaBuild {
  pname = "eplot";
  version = "0-unstable-2026-07-11";
  src = fetchFromGitHub {
    owner = "larsmagne";
    repo = "eplot";
    rev = "51d79d2aeabea76330fb52c098355c541c078ca6";
    hash = "sha256-j2/BtL4+hOHgbAg3lL364pBahxQtJhzn2YP7BldNILA=";
  };
  packageRequires = [ pcsv ];
}
