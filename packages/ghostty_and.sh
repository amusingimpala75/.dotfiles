#!/usr/bin/env bash

# position should be at 300x240, but the TWM doesn't work with that
# window width/height (=160x40) sometimes goes off screen without
# control over window position
open -na Ghostty --args --command="$1" $2
