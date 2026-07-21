#!/usr/bin/env sh

pse=$(ps -e)
echo "$pse" | rg "Ghostty.app" >/dev/null
already_open="$?"

osascript -e 'tell application "Ghostty" to activate'

if [ $already_open -eq "0" ]; then
    osascript -e 'tell application "System Events" to keystroke "t" using command down'
fi
