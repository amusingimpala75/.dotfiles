---
name: create-nix-package
description: Create, update, and validate Nix package derivations from a package name or source URL. Use when asked to package software for Nix/Nixpkgs, generate a derivation, fetch upstream sources, choose build inputs, or make the packaged executable run.
compatibility: Requires an environment with Nix available. Prefer nix-init in headless/non-interactive mode; use nurl when nix-init is unavailable or for source metadata.
---

# Nix Packaging Derivations

Use this skill to package software as a Nix derivation, starting from a package name, repository URL, release URL, archive URL, or language package identifier.

## First response / inputs

The task must have at least one of:

- package name
- upstream URL
- language ecosystem identifier, such as a PyPI/npm/Go/Rust package name

If missing, ask for it. Also ask for any missing required context that changes the derivation shape:

- target location/file to write, unless obvious from the repository
- whether this is for Nixpkgs or a local flake/package set
- expected executable/library name and a simple smoke-test command, if not obvious
- target platform constraints, if relevant

If the user only gives a package name, discover the canonical upstream source before writing the derivation.

## Required workflow

1. Inspect the existing repository structure and packaging conventions.
   - Look for `pkgs/by-name`, `pkgs/top-level/all-packages.nix`, `packages`, `flake.nix`, overlays, existing similar packages, and style conventions.
   - Do not manually install tools. If a needed tool is absent, use `nix run nixpkgs#<tool> -- ...` or ask the user.
2. Fetch/identify upstream source metadata.
   - Prefer `nix-init` in headless/non-interactive mode to generate an initial derivation.
   - If `nix-init` is unavailable or unsuitable, use `nurl` to produce fetcher expressions and hashes.
   - Always verify tags/releases/checksums against upstream, not only generated output.
3. Determine the build system by inspecting source files.
   - Examples: `Cargo.toml`, `go.mod`, `package.json`, `pyproject.toml`, `setup.py`, `meson.build`, `CMakeLists.txt`, `Makefile`, Autotools files, static assets/scripts.
   - Read upstream docs for install/build/test instructions when present.
4. Write or update the derivation in the project’s preferred location.
5. Build it with Nix and fix failures.
6. Run the packaged program or otherwise perform a meaningful smoke test.
7. Leave a concise summary of files changed, build/test commands run, and any caveats.

## Tooling guidance

### nix-init

Use `nix-init` non-interactively/headlessly. Check the installed CLI with `nix-init --help` because flags may vary. Typical usage is along these lines:

```bash
nix-init --headless --url <upstream-url>
```

You can specify the builder (`buildGoModule` etc) with `--builder`

Then treat the generated file as a draft. Review and simplify it; do not blindly accept generated dependencies, metadata, or phases.

If `nix-init` is not on PATH, try:

```bash
nix run self#nix-init -- --help
```

### nurl

Use `nurl` when you need a fetcher and hash, especially for GitHub/GitLab/source archives:

```bash
nurl <url>
```

If `nurl` is not on PATH, try:

```bash
nix run self#nurl -- <url>
```

## Derivation style requirements

Prefer this idiom:

```nix
{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "example";
  version = "1.0.0";

  src = fetchFromGitHub {
    owner = "upstream";
    repo = "example";
    tag = "v${finalAttrs.version}";
    hash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";
  };

  __structuredAttrs = true;
  strictDeps = true;

  installPhase = ''
    runHook preInstall
    install -Dm755 example $out/bin/example
    runHook postInstall
  '';

  meta = {
    description = "Short upstream-accurate description";
    homepage = "https://example.org";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ ];
    mainProgram = "example";
  };
})
```

Requirements:

- Use `mkDerivation (finalAttrs: { ... })` rather than a surrounding `let` block when values can reference `finalAttrs`.
- Set `__structuredAttrs = true;` and `strictDeps = true;` unless the surrounding project has an explicit reason not to.
- Prefer `stdenvNoCC.mkDerivation` over `stdenv.mkDerivation` when no C/C++/Objective-C compiler toolchain is needed.
- Use `stdenv.mkDerivation` only when compilation or compiler-provided setup hooks are actually required.
- Keep dependencies in the correct attributes:
  - `nativeBuildInputs`: tools run on the build machine, including build systems, code generators, wrappers, pkg-config, install helpers.
  - `buildInputs`: libraries linked/used for the host package.
  - `propagatedBuildInputs`: only for dependencies consumers must see.
  - `nativeCheckInputs`: test-only tools.
- Preserve `runHook pre*` and `runHook post*` in custom phases.
- Keep metadata accurate. Do not invent licenses, maintainers, homepage, or descriptions.
- Use `meta.mainProgram` for executable packages.

## Choosing `stdenvNoCC`

Use `stdenvNoCC` for packages that only install or wrap existing files, for example:

- shell/Python/Perl/Ruby scripts that are not compiled by this derivation
- static data, themes, icons, fonts, documentation, completions
- prebuilt single-file scripts or assets
- packages whose build is only copying, patching shebangs, substituting paths, or wrapping scripts

Use regular `stdenv` when building native code, when a compiler is needed during configure/build/check, or when a language builder internally requires it.

## Source and hash handling

- Prefer stable release tags/tarballs over moving branches.
- Use `fetchFromGitHub`, `fetchFromGitLab`, `fetchgit`, `fetchurl`, or language-specific fetchers according to project convention.
- Do not use `lib.fakeHash` in final code unless intentionally leaving a failing placeholder and telling the user.
- If a hash mismatch occurs, update the hash from Nix’s reported `got:` value after verifying the source is expected.
- Prefer `hash = "sha256-...";` over legacy hash attributes unless local style differs.

## Build-system notes

Follow existing project conventions first. Common patterns:

- Rust: prefer `rustPlatform.buildRustPackage`; update `cargoHash` via build output or `nix-prefetch`; run the binary.
- Go: prefer `buildGoModule`; set `vendorHash` or `vendorHash = null` only when appropriate.
- Python: prefer `buildPythonApplication`/`buildPythonPackage` with `pyproject = true` for PEP 517 projects; use `pythonImportsCheck` and a CLI smoke test.
- Node: use the project’s established Node builder; avoid ad-hoc network access during build.
- CMake/Meson/Autotools: use the standard setup hooks in `nativeBuildInputs`.
- Plain scripts/assets: use `stdenvNoCC.mkDerivation`, install files explicitly, patch shebangs, and wrap with runtime dependencies as needed.

## Validation

Always attempt to build the package:

```bash
nix build .#<attr>
```

or, for a standalone derivation:

```bash
nix-build -E 'with import <nixpkgs> {}; callPackage ./package.nix {}'
```

Then test the installed output. For executables, run for example:

```bash
./result/bin/<mainProgram> --help
```

If `--help` is unsupported, use `--version`, a no-op invocation, or another harmless smoke test. For libraries, use imports/check phases or a minimal consumer/import test.

If tests are expensive or require network/secrets/GUI, do not run them blindly. Explain the limitation and run the best safe substitute.

## Quality checklist before final response

- Derivation builds reproducibly without network access during build.
- Packaged executable/library runs or passes a meaningful smoke test.
- `__structuredAttrs` and `strictDeps` are enabled.
- `stdenvNoCC` is used when a compiler is unnecessary.
- `finalAttrs` is used for version/tag/hash references where helpful.
- Dependencies are minimized and in the correct input attributes.
- Metadata is accurate, including `license` and `mainProgram` when applicable.
- The final response lists changed files and exact validation commands run.
