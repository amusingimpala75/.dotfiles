{
  lib,
  fetchFromGitHub,
  melpaBuild,
  nix-update-script,
  tzdata,
}:
melpaBuild {
  pname = "advent-mode";
  version = "0.2-unstable-2026-11-26";

  src = fetchFromGitHub {
    owner = "vkazanov";
    repo = "advent-mode";
    rev = "30997151ffa25ae9122ed1bc94642e98d3a89e65";
    hash = "sha256-zhZCi2bxVh+Lc6cZgPx5UMin+QI/RLkG1SWyBz+eUUE=";
  };

  __structuredAttrs = true;
  strictDeps = true;

  doCheck = true;
  checkPhase = ''
    runHook preCheck
    export TZDIR=${tzdata}/share/zoneinfo
    emacs -Q --batch -L . $(printf -- '-l %s ' test/*.el) -f ert-run-tests-batch-and-exit
    runHook postCheck
  '';

  passthru.updateScript = nix-update-script {
    attrPath = "emacs-advent-mode";
    extraArgs = [
      "--flake"
      "--version=branch"
    ];
  };

  meta = {
    description = "Advent of Code helper mode for Emacs";
    homepage = "https://github.com/vkazanov/advent-mode";
    license = lib.licenses.gpl3Plus;
  };
}
