#!/usr/bin/env bash

version_manifest_url='https://piston-meta.mojang.com/mc/game/version_manifest_v2.json'
version_manifest=$(curl "$version_manifest_url")
latest_version=$(jq -r '.latest.snapshot' <<< "$version_manifest")
latest_version_manifest_url=$(jq -r ".versions[] | select(.id == \"$latest_version\") | .url" <<< "$version_manifest")
latest_version_manifest=$(curl "$latest_version_manifest_url")
asset_index_url=$(jq -r ".assetIndex.url" <<< "$latest_version_manifest")
asset_index=$(curl "$asset_index_url")
objects=$(jq ".objects | to_entries | map(select(.key | (contains(\"music\") or contains(\"record\"))))" <<< "$asset_index")
object_index_lines=$(while IFS= read -r s; do
    filename=$(jq -r .key <<< "$s" | sed 's|.*/||g')
    sha1=$(jq -r .value.hash <<< "$s")
    url="https://resources.download.minecraft.net/${sha1:0:2}/$sha1"
    sha256=$(nix store prefetch-file --name "$filename" "$url" --json | jq -r .hash)
    echo "{\"filename\": \"$filename\", \"url\": \"$url\", \"sha256\": \"$sha256\"}"
done < <( jq -rc '.[]' <<< "$objects" ))
object_index="[$(paste -sd, - <<< "$object_index_lines")]"
echo "$object_index" | jq > index.json
