#!/usr/bin/env bash
# Copy this repo's native UI config into the local DSH home. The app reads a
# real file inside the rootfs; a symlink to the repo may not resolve there.
set -euo pipefail
repo="$(cd "$(dirname "$0")/.." && pwd)"
dst="${DSH_HOME:-$HOME/.dsh}/dsh-go/ui.json"
mkdir -p "$(dirname "$dst")"
cp "$repo/config/ui.json" "$dst"
chmod 644 "$dst"
echo "installed $dst"
