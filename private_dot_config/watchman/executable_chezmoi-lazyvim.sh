#!/usr/bin/env bash
chezmoi add ~/.config/nvim/lazy-lock.json
pushd ~/.local/share/chezmoi || exit
git add private_dot_config/nvim/lazy-lock.json && git commit -m"Update lazy-lock.json"
popd || exit
