#!/usr/bin/env bash
chezmoi add ~/.config/nvim/lazy-lock.json
pushd ~/.local/share/chezmoi
git add private_dot_config/nvim/lazy-lock.json && git commit -m"Update lazyvim config"
popd
