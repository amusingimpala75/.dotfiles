{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
}:
buildNpmPackage (finalAttrs: {
  pname = "pi-mcp-adapter";
  version = "3.3.0";

  src = fetchFromGitHub {
    owner = "nicobailon";
    repo = "pi-mcp-adapter";
    tag = "v${finalAttrs.version}";
    hash = "sha256-eM6LKBmnOC5e2z21nan28XOFuUF7sO8OhqvQMkHe/U8=";
  };

  npmDepsFetcherVersion = 2;
  npmDepsHash = "sha256-5S6QGm8DVebOonY2qZWD9/gigahXAwobGs0PzbTwvJU=";

  # The project's package-lock.json needed the npm-lockfile-fix script run on it
  # Run something like:
  # nix build .#pi-mcp-adapter.src
  # , npm-lockfile-fix result/package-lock.json --cout | jq > mine.json
  # diff -u result/package-lock.json mine.json > packages/by-name/pi-mcp-adapter/package-lock.json.patch
  postPatch = ''
    patch package-lock.json < ${./package-lock.json.patch}
  '';

  dontNpmBuild = true;

  _structuredAttrs = true;
  strictDeps = true;

  meta = {
    description = "Token-efficient MCP adapter for Pi coding agent";
    homepage = "https://github.com/nicobailon/pi-mcp-adapter";
    license = lib.licenses.mit;
  };
})
