#!/usr/bin/env sh

function create_theme() {
    name="$(basename -s .yaml $1)"
    mkdir "./$name"
    variant="$(yq '.variant' < $1)"
    if [ "$variant" = "dark" ]; then
	darkmode=true
    else
	darkmode=false
    fi
    echo "{ darkMode = $darkmode; } // builtins.fromJSON (builtins.readFile ./$name.json)" > "./$name/default.nix"
    yq '.palette' -o json < "./$1" > "./$name/$name.json"
}

for f in ./schemes/base16/*.yaml ; do
    create_theme "$f"
done
