{
  flake.overlays.preface = _: prev: {
    local = prev.lib.makeScope prev.newScope (_: { });
  };

  flake.overlays.flatten = _: prev: prev.local;
}
