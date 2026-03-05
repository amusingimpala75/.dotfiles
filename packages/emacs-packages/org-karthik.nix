{
  fetchgit,
  melpaBuild,
  ...
}:
let
  version = "0-unstable-2026-01-05";

  autoloaded-src = melpaBuild {
    inherit version;
    src = fetchgit {
      url = "https://code.tecosaur.net/tec/org-mode";
      rev = "f9f909681a051c73c64cc7b030aa54d70bb78f80";
      hash = "sha256-MbXBcN6PJ1YSZCyxrg5Fng9pVY9X5FHFB+KAFwQu7zQ=";
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
