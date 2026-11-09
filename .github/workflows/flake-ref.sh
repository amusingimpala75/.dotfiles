#!/usr/bin/env bash
set -euo pipefail

# Materialize the root source: metadata can omit its path/hash with lazy fetching.
nix flake prefetch --json . | jq -er '
  if .storePath == null or .hash == null then
    error("nix flake prefetch did not return storePath and hash")
  else
    "path:\(.storePath)?narHash=\(.hash | @uri)"
  end
'
