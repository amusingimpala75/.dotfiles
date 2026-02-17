#!/bin/sh

if [ -z "$1" ]
then
  echo "No file name supplied"
  exit 1
fi

xattr -dr com.apple.quarantine "$1"
