{
  lib,
  stdenvNoCC,
  makeWrapper,
  babashka,
  fetchgit,
  ...
}:
let
  version = "9.0.0";

in
stdenvNoCC.mkDerivation {
  pname = "orgwebsite";
  inherit version;

  src = fetchgit {
    url = "https://codeberg.org/bzg/orgy";
    rev = version;
    hash = "sha256-ijuuy1VjxD+FZPu/lghWD436NDU5U0WjwLvuNikiqwY=";
    # Because I cannot fathom why he would choose that name,
    # we're going to replace it literally everywhere
    postFetch = ''
      grep -IlrZ . "$out" | xargs -0 -r sed -i 's/orgy/orgwebsite/g'

      find "$out" -mindepth 1 -depth -name '*orgy*' | while IFS= read -r path; do
        dir=$(dirname "$path")
        base=$(basename "$path")
        newBase=$(printf '%s' "$base" | sed 's/orgy/orgwebsite/g')
        if [ "$base" != "$newBase" ]; then
          mv "$path" "$dir/$newBase"
        fi
      done
    '';
  };

  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    runHook preInstall

    mkdir -p "$out/libexec/orgwebsite" "$out/bin"
    cp -r src bb.edn deps.edn "$out/libexec/orgwebsite/"

    makeWrapper ${babashka}/bin/bb "$out/bin/orgwebsite" \
      --add-flags "--config" \
      --add-flags "$out/libexec/orgwebsite/bb.edn" \
      --add-flags "orgwebsite"

    runHook postInstall
  '';

  meta = {
    description = "Static blog generator that turns Org files into a website";
    homepage = "https://codeberg.org/bzg/orgy";
    license = lib.licenses.epl20;
    mainProgram = "orgwebsite";
    platforms = lib.platforms.unix;
  };
}
