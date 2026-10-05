{
  lib,
  pi-coding-agent,
  stdenvNoCC,
}:
lib.mapAttrs
  (
    name: entry:
    stdenvNoCC.mkDerivation {
      pname = "pi-extension-${name}";
      inherit (pi-coding-agent) version;

      src = "${pi-coding-agent.src}/packages/coding-agent/examples/extensions/${entry}";

      __structuredAttrs = true;
      strictDeps = true;
      dontUnpack = true;
      dontBuild = true;

      installPhase = ''
        runHook preInstall

        mkdir -p "$out"
        if [ -d "$src" ]; then
          cp -r "$src"/. "$out"/
        else
          cp "$src" "$out/index.ts"
        fi

        runHook postInstall
      '';

      meta = {
        description = "Pi's ${name} example extension";
        inherit (pi-coding-agent.meta) homepage license platforms;
      };
    }
  )
  {
    commands = "commands.ts";
    notify = "notify.ts";
    plan-mode = "plan-mode";
    permission-gate = "permission-gate.ts";
    protected-paths = "protected-paths.ts";
    subagent = "subagent";
    tools = "tools.ts";
  }
