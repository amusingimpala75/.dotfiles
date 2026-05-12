{
  flake.overlays.preface = _: prev: {
    local = prev.lib.makeScope prev.newScope (_: { });
  };

  flake.overlays.flatten = _: prev: if (prev ? local) then prev.local else { };
}
