{
  flake.overlays.lumafly-darwin = final: prev: {
    lumafly =
      if prev.stdenv.isLinux then
        prev.lumafly
      else
        let
          package = prev.lumafly.overrideAttrs (o: {
            meta = o.meta // {
              platforms = final.lib.platforms.darwin;
            };
          });
        in
        final.mkDarwinApplication {
          inherit package;
          exeName = "lumafly";
          appName = "Lumafly";
          img = "${package.src}/Lumafly/Assets/Lumafly.png";
        };
  };
}
