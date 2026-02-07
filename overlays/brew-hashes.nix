final: prev:
let
  replaceHash = package: hash: package.overrideAttrs (old: {
    src = final.fetchurl {
      url = builtins.head old.src.urls;
      inherit hash;
    };
  });
in
{
  brewCasks = prev.brewCasks // (with prev.brewCasks; {
    minecraft = replaceHash minecraft "sha256-gsWdmzKFAX4tbRsDX1OUFcH+tQ14daTwNMwprycye0g=";
    steam = replaceHash steam "sha256-X1VnDJGv02A6ihDYKhedqQdE/KmPAQZkeJHudA6oS6M=";
  });
}
