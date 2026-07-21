{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
}:

buildNpmPackage (finalAttrs: {
  pname = "pi-subagents";
  version = "0.14.3";

  src = fetchFromGitHub {
    owner = "tintinweb";
    repo = "pi-subagents";
    tag = "v${finalAttrs.version}";
    hash = "sha256-ZztgK9TUrpLsTSmYTOlHu8f6P5G/EA3MmVhqSfFZLQA=";
  };

  npmDepsFetcherVersion = 2;
  npmDepsHash = "sha256-SSk/wL7T/DkkaOLAToI/eW8zReuwGnJE4Wfbc4KXcno=";

  # The project's package-lock.json needed the npm-lockfile-fix script run on it
  postPatch = ''
    cp ${./package-lock.json} ./package-lock.json
  '';

  dontNpmBuild = true;

  __structuredAttrs = true;
  strictDeps = true;

  meta = {
    description = "Claude Code like Sub-agents for Pi — parallel execution, live widget, custom agent types, mid-run steering and more";
    homepage = "https://github.com/tintinweb/pi-subagents";
    license = lib.licenses.mit;
    # mainProgram = "pi-subagents";
  };
})
