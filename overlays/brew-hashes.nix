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
      steam = replaceHash steam "sha256-4av7qqe+Pg9IoODUwxMjPgWGGx0mrzKDDdyDi+iPJpE=";
    });
}
