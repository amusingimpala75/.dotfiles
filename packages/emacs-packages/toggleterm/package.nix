{
  lib,
  melpaBuild,
  ...
}:
melpaBuild {
  pname = "toggleterm";
  version = "0-unstable-2025-08-30";
  src = lib.sources.sourceByRegex ./. [ "toggleterm.el" ];
}
