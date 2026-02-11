#!/usr/bin/env sh

if [ "$#" -lt "2" ]; then
    echo "usage: run-ntfy-when-done [server] [cmd] [args...]"
    exit 1
fi

SERVER="$1"
shift 1
CMD="${@}"

screen-saver

caffeinate -d $CMD

if [ "$?" -eq "0" ]; then
    ntfy send "$SERVER" "${@} succeeded"
else
    ntfy send "$SERVER" "${@} failed"
fi
