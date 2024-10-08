#!/usr/bin/env bash

# TODO: install nix

if [ $(uname) = "Darwin" ]; then
  # Build nix-darwin configuration
  nix build .#darwinConfigurations.$(hostname -s).system

  # Switch to nix-darwin config
  ./result/sw/bin/darwin-rebuild switch --flake .

  # Remove result prior to running home-manager
  rm result
else
  sudo nixos-rebuild switch --flake .
fi

# Build home-manager configurations
nix build .#homeConfigurations."$(id -un)_$(hostname -s)".activationPackage

# Switch to the home-manager config
./result/home-path/bin/home-manager switch --flake .#"$(id -un)_$(hostname -s)"

# Cleanup the results folder
rm result
