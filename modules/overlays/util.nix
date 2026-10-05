{
  lib,
  ...
}:
{
  flake.overlays.preface = _: prev: {
    local = lib.makeScope prev.newScope (_: { });
  };

  flake.overlays.flatten = _: prev: prev.local;
}
