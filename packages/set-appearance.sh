#!/usr/bin/env sh

if [ -z "$1" ]
then
    echo "usage: set-appearance [light|dark]"
    exit 1
fi

SCRIPT=$(cat <<EOF
tell app "System Events"
    tell appearance preferences
        set dark mode to $1
    end tell
end tell
EOF
)


/usr/bin/osascript -e "$SCRIPT"
