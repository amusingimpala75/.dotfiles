{
  lib,
  fetchFromGitHub,
  fd,
  yq-go,
  stdenv,
  ...
}:
let
  inherit (builtins) attrNames fromJSON mapAttrs readDir readFile stringLength substring;
  inherit (stdenv) mkDerivation;

  get-schemes = type: mkDerivation {
    name = "schemes-json";
    src = fetchFromGitHub {
      owner = "tinted-theming";
      repo = "schemes";
      rev = "4ff7fe1cf77217393ed0981a1de314f418c28b49";
      sha256 = "sha256-PX66lrB/aqFnr6sCQUBzpTSCbsLbC7CEt4q02D0fJ3M=»;";
    };

    phases = [ "installPhase" ];

    buildInputs = [ fd yq-go ];

    installPhase = ''
      mkdir $out
      echo $PWD
      ls .
      for f in $(fd "\.yaml" $src/${type});
      do
      echo $f
      yq '.palette * {"darkMode": .variant == "dark"}' -o json < $f > $out/$(basename -s .yaml $f).json
      # yq '.palette' -o json < $f > $out/$(basename -s .yaml $f).json
      done
    '';
  };

  schemes-base16-jsons = get-schemes "base16";
  schemes-base24-jsons = get-schemes "base24";

  strip-yaml = path-str: substring 0 ((stringLength path-str) - (stringLength ".yaml")) path-str;
  scheme-names = jsons: map strip-yaml (attrNames (readDir "${jsons}"));

  read-scheme = jsons: name: readFile "${jsons}/${name}.json";

  scheme-attrs = jsons: name:
    let
      attrs = fromJSON (read-scheme jsons name);
    in
      if builtins.hasAttr "base10" attrs then attrs
      else attrs // {
        base10 = attrs.base00;
        base11 = attrs.base00;
        base12 = attrs.base08;
        base13 = attrs.base0A;
        base14 = attrs.base0B;
        base15 = attrs.base0C;
        base16 = attrs.base0D;
        base17 = attrs.base0E;
      };

  attr-is-color = name: (substring 0 4 name) == "base";
  strip-hash = value: substring 1 ((stringLength value) - 1) value;
  strip-attr-hash = name: value: if (attr-is-color name) then strip-hash value else value;
  strip-hashes = set: mapAttrs strip-attr-hash set;

  gen = jsons: lib.genAttrs (scheme-names jsons) (scheme: strip-hashes (scheme-attrs jsons scheme));
in {
  base16 = gen schemes-base16-jsons;
  base24 = gen schemes-base24-jsons;
}
