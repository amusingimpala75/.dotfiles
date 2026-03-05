{
  lib,
  melpaBuild,
  ...
}:
melpaBuild {
  pname = "word-count";
  version = "0-unstable-2026-02-16";
  src = lib.sources.sourceByRegex ./. [ "word-count.el" ];
}
