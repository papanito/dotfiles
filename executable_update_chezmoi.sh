#!/usr/bin/env bash
echo "# Update home-manager flake"
pushd ~/.config/home-manager
nix flake update
popd

echo "# Add some files which might be outdaed"
chezmoi add ~/.config/nvim/lazyvim.json
