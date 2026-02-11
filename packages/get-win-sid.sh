#!/usr/bin/env bash

USERNAME="$1"

function escape_str() {
    sed 's/\\/\\\\/g'
}

# Stupid Windows line endings cost me half an hour
function unwindows() {
    tr '\r' '\n'
}

if [ ! -d "/mnt/c/Users" ]; then
    echo "Are you sure this is a WSL system?"
    exit 1
fi

PROFILE_LIST_KEY='HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList'
ESCAPED_PLK=$(escape_str <<< "$PROFILE_LIST_KEY")

# Get list of sids
SUBQUERY=$(escape_str <<< "$PROFILE_LIST_KEY\\S")
IFS=$'\n'
for line in $(reg.exe query "$PROFILE_LIST_KEY" | escape_str | rg -F "$SUBQUERY" | unwindows); do
    SID=${line#"$ESCAPED_PLK\\\\"}
    # What have I done to this world to deserve this?
    if reg.exe query "$PROFILE_LIST_KEY\\$SID" | tr ' ' '\n' | escape_str | grep -iq "C:\\\\\\\\Users\\\\\\\\$USERNAME"; then
       echo "$SID"
    fi
done
