#!/usr/bin/env bash
echo "❄️Update home-manager flake"
pushd ~/.config/home-manager || exit
nix flake update
popd || exit

echo "🦊 Commit flake.lock to git"
pushd ~/.local/share/chezmoi || exit
chezmoi add ~/.config/home-manager/flake.lock
git add private_dot_config/private_home-manager/private_flake.lock && git commit -m"home-manager: Update flake"
popd || exit

echo "🦊 Add herdr rules"
chezmoi add ~/.config/herdr/config.toml

echo "🦊 Add lazyvim config"
chezmoi add ~/.config/nvim/lazyvim.json

echo "🦊 Add omp config"
chezmoi add ~/.omp/agent/config.yml

echo "🦊 Add tuios config"
chezmoi add ~/.config/tuios/config.toml

echo "👁️‍🗨️ Register all watchmen config files"
for file in ~/.config/watchman/*.json; do
  echo "Registering $file..."
  watchman -j <"$file"
done
popd || exit
