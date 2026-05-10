#!/usr/bin/env bash

function download_image() {
  set="$1"
  number=$(printf "%03d" "$2")
  outfile="$set/$number.jpg"

  curl -sSL "https://www.mtgpics.com/pics/art/$set/$number.jpg" -o "$outfile"

  if ! file "$outfile" | grep "JPEG"; then
    echo "missing image"
    rm "$outfile"
    return 1
  fi
  return 0
}

if [ "$1" == "" ]; then
  echo "Missing set code"
  exit 1
else
  set="$1"
fi

if [ "$2" == "" ]; then
  echo "Missing image count"
  exit 1
else
  count="$2"
fi

mkdir -p "$1"

found=0
index=0
while [[ "$found" -lt "$count" ]]
do
  echo $index
  if download_image "$1" "$index"; then
    ((found += 1))
  fi
  ((index += 1))
  if [ "$index" -ge 1000 ]; then
    echo $((count - found))
    exit 1
  fi
done
