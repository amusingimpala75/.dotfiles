{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
}:

buildNpmPackage (finalAttrs: {
  pname = "pi-subagents";
  version = "0.19.0";

  src = fetchFromGitHub {
    owner = "tintinweb";
    repo = "pi-subagents";
    tag = "v${finalAttrs.version}";
    hash = "sha256-1K6U5+2qLgOV7lUWbvqUne/Pf7oMRDf40GXLl8gv6Bk=";
  };

  npmDepsFetcherVersion = 2;
  npmDepsHash = "sha256-MfBxGLUgfzO0RcwggITW3XU4rpxeGGpVXM2Qmm/E8tc=";

  # The project's package-lock.json needed the npm-lockfile-fix script run on it
  # Run something like:
  # nix build .#pi-subagents.src
  # , npm-lockfile-fix result/package-lock.json --cout | jq > mine.json
  # diff -u result/package-lock.json mine.json > packages/by-name/pi-subagents/package-lock.json.patch
  postPatch = ''
    patch package-lock.json < ${./package-lock.json.patch}
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
