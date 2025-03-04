#!/usr/bin/env bash
NL=$'\n'

directories=(
    "/Applications"
    "/System/Applications"
    "/System/Applications/Utilities"
    "/Applications/Utilities"
    "/Applications/KiCad"
    "$HOME/Applications"
    "$HOME/Applications/Home Manager Apps"
)
apps=""
for dir in "${directories[@]}"; do
    a=$(fd .app "$dir" -d 1)
    if [ "$a" != "" ]; then
        if [ "$dir" != "${directories[0]}" ]; then
            apps="$apps$NL"
        fi
        apps="$apps$a"
    fi
done

app=$(echo "$apps" | fzf --ignore-case --cycle --border=sharp --border-label="Application Launcher" --no-info --no-separator --history="$HOME/.local/state/launcher/hist" --scheme=history)
open -na "$app"
