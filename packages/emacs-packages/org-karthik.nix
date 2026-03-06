{
  fetchFromGitHub,
  melpaBuild,
  ...
}:
let
  version = "0-unstable-2026-02-05";

  autoloaded-src = melpaBuild {
    inherit version;
    src = fetchFromGitHub {
      owner = "karthink";
      repo = "org-mode";
      rev = "ceffe239a6ae643fb526388d99a7816c5115166f";
      hash = "sha256-qhXd9HO5Q+762MMZ07S+cm1gFZH+AUorziYzV02y+7Y=";
    };
    pname = "org-karthik-source";
    buildPhase = ''
      make autoloads
    '';
    installPhase = ''
      mkdir -p $out
      cp -R lisp/* doc etc $out/
    '';
  };
in
melpaBuild {
  inherit version;
  pname = "org";
  src = autoloaded-src;
}
