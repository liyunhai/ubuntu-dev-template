#!/usr/bin/env bash
set -Eeuo pipefail

echo "[verify-herdr] checking Herdr..."
command -v herdr >/dev/null
herdr --version
[[ -f "${HOME}/.config/herdr/config.toml" ]]
herdr config check
echo "[verify-herdr] ok"
