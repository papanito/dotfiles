#!/usr/bin/env bash
echo "🧹 Run Cleanup"
echo "🧹 Expire home-manager generations"
home-manager expire-generations -30days
echo "🧹 Cleanup atuin failed commands"
atuin search "" --exit=127 --delete --filter-mode global
