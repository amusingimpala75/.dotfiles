#!/usr/bin/env bash

include_shorts=false

function print_usage() {
    printf 'usage: youtube-rss <handle> [--include-shorts]\n' >&2
}

if (($# > 2)); then
    print_usage
    exit 1
fi

handle=""

while (($#)); do
    case "$1" in
        --include-shorts)
            include_shorts=true
            ;;
        --*)
            printf 'unknown option: %s\n' "$1" >&2
            exit 1
            ;;
        *)
            if [ -z "$handle" ]; then
                handle="$1"
            else
                print_usage
                exit 1
            fi
            ;;
    esac
    shift
done

if [ -z "$handle" ]; then
    print_usage
    exit 1
fi

channel_url="https://www.youtube.com/@$handle"

if ! page="$(
   curl \
        --fail \
        --silent \
        --show-error \
        --location \
        --connect-timeout 10 \
        --max-time 30 \
        --retry 3 \
        --retry-delay 1 \
        "$channel_url"
     )"; then
    printf 'Could not fetch channel page for @%s\n' "$handle" >&2
    exit 1
fi

channel_rss_url=$(htmlq 'link[type="application/rss+xml"]' -a href <<< "$page")

if [ -z "$channel_rss_url" ]; then
    printf 'Invalid page fetched\n' >&2
fi

if [[ "$include_shorts" == true ]]; then
    echo "$channel_rss_url"
    exit 0
else
    without_shorts_url=${channel_rss_url//channel_id=UC/playlist_id=UULF}
    echo "$without_shorts_url"
    exit 0
fi
