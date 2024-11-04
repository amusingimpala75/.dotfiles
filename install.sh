#!/usr/bin/env bash

DOTDIR="$HOME/.dotfiles"

# nix run nixpkgs#git -- clone https://github.com/amusingimpala75/.dotfiles "$DOTDIR"

if [ "$(uname)" = "Darwin" ]; then
    nix run nix-darwin/master --extra-experimental-features "nix-command flakes" -- switch --flake "$DOTDIR"
else
    sudo nixos-rebuild switch --flake "$DOTDIR"
fi

nix run home-manager/master --extra-experimental-features "nix-command flakes" -- switch --flake "$DOTDIR"#"$(id -un)_$(hostname -s)"
