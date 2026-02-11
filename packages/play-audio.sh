#!/usr/bin/env sh

if [ $# -lt 1 ]
then
    echo "usage: play-audio <audio file> [loop times]"
    exit 1
fi

FILE="$1"
LOOP="$2"

if [ $# -lt 2 ]
then
    LOOP=1
fi

for _ in $(seq 1 $LOOP)
do
    ffplay -v 0 -nodisp -autoexit "$FILE"
done
