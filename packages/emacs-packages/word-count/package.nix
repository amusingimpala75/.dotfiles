{
  lib,
  trivialBuild,
  ...
}:
trivialBuild {
  pname = "word-count";
  version = "git+2026-02-16";
  src = lib.sources.sourceByRegex ./. [ "word-count.el" ];
}
