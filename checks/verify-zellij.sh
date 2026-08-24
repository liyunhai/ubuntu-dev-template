#!/usr/bin/env bash
set -Eeuo pipefail

echo "[verify-zellij] checking Zellij..."
command -v zellij >/dev/null
zellij --version
[[ -f "${HOME}/.config/zellij/config.kdl" ]]
echo "[verify-zellij] ok"
