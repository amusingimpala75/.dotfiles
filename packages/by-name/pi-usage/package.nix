{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
}:
buildNpmPackage (finalAttrs: {
  pname = "pi-usage";
  version = "0.68.3";

  src = fetchFromGitHub {
    owner = "narumiruna";
    repo = "pi-extensions";
    tag = "@narumitw/pi-usage@${finalAttrs.version}";
    hash = "sha256-m5j0y94JxSWPo68M3mTyhmnbJKkn0BHt4B/8ylqH9T0=";
  };

  __structuredAttrs = true;
  strictDeps = true;

  npmDepsHash = "sha256-zoEcoyErra23sEuTB6FWb5ddAJLHUBnqyRoy7Cef16M=";
  npmWorkspace = "packages/pi-usage";

  preBuild = ''
    npm --workspace @narumitw/pi-tui-kit run build
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p "$out/node_modules/@narumitw/pi-tui-kit"
    cp -r packages/pi-usage/{dist,docs,package.json,README.md,LICENSE} "$out/"
    cp -r packages/pi-tui-kit/{dist,package.json,LICENSE} "$out/node_modules/@narumitw/pi-tui-kit/"

    # Pi supplies the peer dependencies. These three packages have no runtime dependencies.
    cp -r packages/pi-tui-kit/node_modules/{diff,highlight.js} "$out/node_modules/"
    cp -r node_modules/grok-mermaid "$out/node_modules/"

    runHook postInstall
  '';

  doInstallCheck = true;
  installCheckPhase = ''
    runHook preInstallCheck

    node --input-type=module <<'EOF'
    import assert from 'node:assert/strict';
    import { fileURLToPath } from 'node:url';
    import { createJiti } from 'jiti';
    const alias = Object.fromEntries(
      ['pi-ai', 'pi-coding-agent', 'pi-tui'].map(name => {
        const id = '@earendil-works/' + name;
        return [id, fileURLToPath(import.meta.resolve(id))];
      })
    );
    const jiti = createJiti(import.meta.url, { alias });
    const extension = await jiti.import(process.env.out + '/dist/index.ts');
    assert.equal(typeof extension.default, 'function');
    const tui = await jiti.import(process.env.out + '/node_modules/@narumitw/pi-tui-kit/dist/index.js');
    assert.equal(typeof tui.runMenu, 'function');
    EOF

    runHook postInstallCheck
  '';

  meta = {
    description = "Pi extension for provider usage, limits, reset times, API balances, and Codex Fast mode";
    homepage = "https://github.com/narumiruna/pi-extensions/tree/main/packages/pi-usage";
    license = lib.licenses.mit;
    platforms = lib.platforms.all;
  };
})
