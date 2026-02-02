{
  lib,
  trivialBuild,
  ...
}:
trivialBuild {
  pname = "toggleterm";
  version = "git+2025-8-30";
  src = lib.sources.sourceByRegex ./. [ "toggleterm.el" ];
}
