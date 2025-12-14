{
  emacs,
  emacsPackagesFor,
  fetchFromGitea,

  pkg-config,
  gcc,
  mupdf,
  gnumake,
  ...
}:
let
  epkgs = emacsPackagesFor emacs;
in
(epkgs.melpaBuild {
  ename = "reader";
  pname = "emacs-reader";
  version = "20250630";
  src = fetchFromGitea {
    domain = "codeberg.org";
    owner = "divyaranjan";
    repo = "emacs-reader";
    rev = "5f80aa8ed2e13772174ef2517ad75c617d44bd4e";
    hash = "sha256-BJM69NHfq6MJJE3UG1442ttPBGBAsn3jxZcpP+LtmxQ=";
  };
  files = ''(:defaults "render-core.so")'';
  nativeBuildInputs = [ pkg-config ];
  buildInputs = [ gcc mupdf gnumake pkg-config ];
  preBuild = "make clean all";
})
