#!/usr/bin/env bash
echo "❄️Update home-manager flake"
pushd ~/.config/home-manager || exit
nix flake update
popd || exit

echo "🦊 Commit flake.lock to git"
pushd ~/.local/share/chezmoi || exit
chezmoi add ~/.config/home-manager/flake.lock
git add private_dot_config/home-manager/flake.lock && git commit -m"home-manager: Update flake"
popd || exit

echo "🦊 Add opnesnitch rules"
chezmoi add ~/.config/opensnitch/settings.conf

echo "🦊 Add lazyvim config"
chezmou add ~/.config/nvim/lazyvim.json

echo "👁️‍🗨️ Register all watchmen config files"
for file in ~/.config/watchman/*.json; do
  echo "Registering $file..."
  watchman -j <"$file"
done
echo "Registering 'movies-sync'"
watchman -- trigger /home/papanito/Videos/Movies movies-sync "*.avi" "*.mp4" "*.srt" "*.mkv" -- sh -c "rsync ~/Videos/Movies/ nixos@10.0.0.10:/media/media/ -rv --update --ignore-existing -e 'ssh -i /home/papanito/.ssh/id_paperless_sync -o Batchmode=yes -o StrictHostKeyChecking=accept-new'"
popd || exit
