{
  flake.overlays.brew-hashes =
    final: prev:
    let
      replaceHash =
        package: hash:
        package.overrideAttrs (old: {
          src = final.fetchurl {
            url = builtins.head old.src.urls;
            inherit hash;
          };
        });
    in
    {
      brewCasks =
        prev.brewCasks
        // (with prev.brewCasks; {
          battle-net =
            (replaceHash battle-net "sha256-VH05EhAkeKzXhTWVnHe1c347F86B49Wq35EDPJt0Cq8=").overrideAttrs
              (o: {
                unpackPhase = ''
                  unzip $src
                '';
                installPhase = ''
                  mkdir -p $out/Applications
                  mv Battle.net-Setup.app $out/Applications/
                '';
                nativeBuildInputs = [ final.unzip ];
              });
          dwarf-fortress-lmp = dwarf-fortress-lmp.overrideAttrs (o: {
            nativeBuildInputs = [ final.undmg ];
            unpackPhase = ''
              undmg $src
            '';
            installPhase =
              let
                version = builtins.replaceStrings [ "+" ] [ " " ] o.version;
              in
              ''
                mkdir -p $out/Applications
                rm "Lazy Mac Pack v${version}/DF v0.47.05/libs/SDL_image.framework/Frameworks"
                mv "Lazy Mac Pack v${version}" $out/Applications/
              '';
          });
          steam = replaceHash steam "sha256-4av7qqe+Pg9IoODUwxMjPgWGGx0mrzKDDdyDi+iPJpE=";
        });
    };
}
