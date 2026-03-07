#!/usr/bin/env bash
echo "# Update home-manager flake"
pushd ~/.config/home-manager
nix flake update
popd

echo "# Commit flake.lock to git"
pushd ~/.local/share/chezmoi
chezmoi add ~/.config/home-manager/flake.lock
git add private_dot_config/home-manager/flake.lock && git commit -m"home-manager: Update flake"

echo "# Add some files which might be outdaed"
chezmoi add ~/.config/nvim/lazyvim.json
git add private_dot_config/nvim/lazyvim.json && git commit -m"Update lazyvim config"
