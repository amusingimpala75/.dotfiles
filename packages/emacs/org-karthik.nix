{
  emacs,
  emacsPackagesFor,
  fetchgit,
  ...
}:
let
  epkgs = emacsPackagesFor emacs;
  rev = "f9f909681a051c73c64cc7b030aa54d70bb78f80";
  hash = "sha256-MbXBcN6PJ1YSZCyxrg5Fng9pVY9X5FHFB+KAFwQu7zQ=";
in
epkgs.trivialBuild {
  pname = "org-karthink";
  version = "git+2026-1-5";
  src = fetchgit {
    url = "https://code.tecosaur.net/tec/org-mode";
    inherit rev hash;
  };
  packageRequires = epkgs.org.packageRequires;
  sourceRoot = "org-mode-${builtins.substring 0 7 rev}/lisp";
  # TODO: autoloads
}
