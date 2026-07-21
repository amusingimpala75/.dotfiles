#!/usr/bin/env bash

# Parse parameters for --dry-run param
dry_run=false

while (($#)); do
    case "$1" in
        --dry-run)
            dry_run=true
            ;;
        *)
            echo "Unknown option: $1" >&2
            exit 1
            ;;
    esac
    shift
done

# Get the branch name, default to origin
branch=$(gum input --placeholder "origin")
if [ -z "$branch" ]; then
    branch="origin"
fi
echo "Branch: $branch"

# If the branch doesn't exist, make it with a dummy branch
if ! git remote | grep "$branch" >/dev/null 2>&1; then
    git remote add "$branch" .
fi

# Ask for repo name, default to the current folder name
default_repo=$(basename "$PWD")
repo=$(gum input --placeholder "$default_repo")
if [ -z "$repo" ]; then
    repo="$default_repo"
fi
echo "Repo name: $repo"

# Fetch runtime defined urls
manual_urls=()
while true; do
    if gum confirm "Manually add url?" --default=No; then
        manual_urls+=("$(gum input)")
    else
        break
    fi
done

# Full future path, without the /<repo-name>.git
if [ -z "$GIT_REMOTE_SETUP_PROVIDERS" ]; then
    GIT_REMOTE_SETUP_PROVIDERS="$HOME/.config/git-remote-setup/providers.txt"
fi

# Special case: radicle
radicle_url=$(git remote get-url rad --push 2>/dev/null || true)
if [ -n "$radicle_url" ]; then
    export radicle_url
fi

export repo
mapfile -t urls < <(envsubst < "$GIT_REMOTE_SETUP_PROVIDERS")

urls+=("${manual_urls[@]}")


# Select fetch and push urls
push_urls=$(printf '%s\n' "${urls[@]}" | gum choose --header="Fetch URLs:" --no-limit)
fetch_url="$(gum choose --header="Push URL: " <<< "$push_urls")"

# Set the fetch url
if $dry_run; then
    echo "git remote set-url $branch $fetch_url"
else
    git remote set-url "$branch" "$fetch_url"
fi

# Set the push urls
while IFS= read -r url; do
    cmd=(git remote set-url "$branch" --add --push "$url")
    if $dry_run; then
        printf '%q ' "${cmd[@]}"
        echo
    else
        "${cmd[@]}"
    fi
done <<< "$push_urls"
