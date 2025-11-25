{
  emacs,
  emacsPackagesFor,
  lib,
  ...
}:
let
  epkgs = emacsPackagesFor emacs;
in
epkgs.trivialBuild {
  pname = "toggleterm";
  version = "git+2025-8-30";
  src = lib.sources.sourceByRegex ./. [ "toggleterm.el" ];
}
