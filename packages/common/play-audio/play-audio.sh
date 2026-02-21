#!/usr/bin/env sh

if [ $# -lt 1 ]
then
    echo "usage: play-audio <audio file> [loop times]"
    exit 1
fi

FILE="$1"
LOOP=""

if [ $# -lt 2 ]
then
    LOOP=1
else
    LOOP="$2"
fi

if [ ! -f "$FILE" ]
then
    echo "$FILE: file not found"
    exit 1
fi

if ! ffprobe "$FILE" >/dev/null 2>&1
then
    echo "$FILE: not a valid audio file"
    exit 1
fi

ffprobe "$FILE" -v quiet -show_entries format_tags=title,composer -of json |
    jaq -r '.format.tags | "\(.composer) - \(.title | gsub("_"; " "))"'

for _ in $(seq 1 "$LOOP")
do
    ffplay -nodisp -autoexit "$FILE" >/dev/null 2>&1
done
