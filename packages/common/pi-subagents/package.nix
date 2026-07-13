{
  lib,
  buildNpmPackage,
  fetchgit,
}:

buildNpmPackage (finalAttrs: {
  pname = "pi-subagents";
  version = "0.34.0";

  src = fetchgit {
    url = "https://github.com/nicobailon/pi-subagents.git";
    tag = "v${finalAttrs.version}";
    hash = "sha256-RN8f5cT/oRSkqwOAmvJ2uJsOmScYb0ijwixTd75iGHk=";
  };

  npmDepsHash = "sha256-IJJ3hceNvHUr5QFIa/+0tnxNiEPh7jifE9dvPHrLE58=";

  dontNpmBuild = true;

  __structuredAttrs = true;
  strictDeps = true;

  meta = {
    description = "Pi extension for delegating tasks to subagents with chains, parallel execution, and TUI clarification";
    homepage = "https://github.com/nicobailon/pi-subagents";
    license = lib.licenses.mit;
    mainProgram = "pi-subagents";
  };
})
