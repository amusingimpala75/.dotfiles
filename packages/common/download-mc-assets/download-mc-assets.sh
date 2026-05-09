#!/usr/bin/env bash

VERSIONS_MANIFEST_URL="https://piston-meta.mojang.com/mc/game/version_manifest_v2.json"
VERSIONS_MANIFEST="versions_manifest.json"

curl "$VERSIONS_MANIFEST_URL" > "$VERSIONS_MANIFEST"

SNAPSHOT_LATEST=$(jq -r '.latest.snapshot' "$VERSIONS_MANIFEST")
SNAPSHOT_MANIFEST_URL=$(jq -r ".versions[] | select(.id | contains(\"$SNAPSHOT_LATEST\")) | .url" "$VERSIONS_MANIFEST")
SNAPSHOT_MANIFEST="version_manifest.json"

curl "$SNAPSHOT_MANIFEST_URL" > "$SNAPSHOT_MANIFEST"

ASSET_INDEX_URL=$(jq -r '.assetIndex.url' "$SNAPSHOT_MANIFEST")
ASSET_INDEX="asset_index.json"

curl "$ASSET_INDEX_URL" > "$ASSET_INDEX"

FILTER='contains("records") or contains("music")'
FILES=$(jq -r ".objects | with_entries(select(.key | $FILTER)) | to_entries | .[] .key" "$ASSET_INDEX")
FILE_HASHES=$(jq -r ".objects | with_entries(select(.key | $FILTER)) | .[] | .hash" "$ASSET_INDEX")

mkdir -p "$SNAPSHOT_LATEST"

while [ -n "$FILES" ]; do
    REMOTE_FILE_NAME=$(head -n 1 <<< "$FILES")
    FILE_NAME="$SNAPSHOT_LATEST/$REMOTE_FILE_NAME"
    FILE_HASH=$(head -n 1 <<< "$FILE_HASHES")
    FILE_HASH_FIRST_TWO="${FILE_HASH%"${FILE_HASH#??}"}"
    FILE_URL="https://resources.download.minecraft.net/$FILE_HASH_FIRST_TWO/$FILE_HASH"

    echo "$FILE_NAME"
    mkdir -p "$(dirname "$FILE_NAME")"
    curl "$FILE_URL" > "$FILE_NAME"

    FILES=$(tail -n +2 <<< "$FILES")
    FILE_HASHES=$(tail -n +2 <<< "$FILE_HASHES")
done

rm "$VERSIONS_MANIFEST"
rm "$SNAPSHOT_MANIFEST"
rm "$ASSET_INDEX"
