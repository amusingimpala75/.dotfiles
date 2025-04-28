#!/usr/bin/env bash
NL=$'\n'

directories=(
    "/Applications"
    "/System/Applications"
    "$HOME/Applications"
)
apps=""
for dir in "${directories[@]}"; do
    a=$(fd -e '.app' --prune -a --search-path "$dir" -L | xargs -I {} basename {} | sed 's/.app//')
    if [ "$a" != "" ]; then
        if [ "$dir" != "${directories[0]}" ]; then
            apps="$apps$NL"
        fi
        apps="$apps$a"
    fi
done

app=$(echo "$apps" | fzf --ignore-case --cycle --border=sharp --border-label="Application Launcher" --no-info --no-separator --history="$HOME/.local/state/launcher/hist" --scheme=history)
open -na "$app"
