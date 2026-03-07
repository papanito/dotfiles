#!/usr/bin/env bash
echo "# Update home-manager flake"
pushd ~/.config/home-manager || exit
nix flake update
popd || exit

echo "# Commit flake.lock to git"
pushd ~/.local/share/chezmoi || exit
chezmoi add ~/.config/home-manager/flake.lock
git add private_dot_config/home-manager/flake.lock && git commit -m"home-manager: Update flake"
popd || exit
