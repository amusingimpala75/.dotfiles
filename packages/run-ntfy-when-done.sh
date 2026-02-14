#!/usr/bin/env sh

if [ "$#" -lt "2" ]; then
    echo "usage: run-ntfy-when-done [server] [cmd] [args...]"
    exit 1
fi

SERVER="$1"
shift 1
CMD="${*}"

screen-saver

#shellcheck disable=SC2086
if caffeinate -d $CMD; then
    ntfy send "$SERVER" "$CMD succeeded"
else
    ntfy send "$SERVER" "$CMD failed"
fi
