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

  schemes-json = mkDerivation {
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
      for f in $(fd "\.yaml" $src/base16);
      do
      echo $f
      yq '.palette * {"darkMode": .variant == "dark"}' -o json < $f > $out/$(basename -s .yaml $f).json
      # yq '.palette' -o json < $f > $out/$(basename -s .yaml $f).json
      done
    '';
  };

  strip-yaml = path-str: substring 0 ((stringLength path-str) - (stringLength ".yaml")) path-str;
  scheme-names = map strip-yaml (attrNames (readDir "${schemes-json}"));

  read-scheme = name: readFile "${schemes-json}/${name}.json";
  scheme-attrs = name: fromJSON (read-scheme name);

  attr-is-color = name: (substring 0 4 name) == "base";
  strip-hash = value: substring 1 ((stringLength value) - 1) value;
  strip-attr-hash = name: value: if (attr-is-color name) then strip-hash value else value;
  strip-hashes = set: mapAttrs strip-attr-hash set;

in lib.genAttrs scheme-names (scheme: strip-hashes (scheme-attrs scheme))
