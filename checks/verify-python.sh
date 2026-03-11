#!/usr/bin/env bash
set -Eeuo pipefail

echo "[verify-python] checking python and python tooling..."
command -v python3 >/dev/null
command -v pipx >/dev/null
command -v uv >/dev/null || [[ -x "$HOME/.local/bin/uv" ]]

echo "[verify-python] versions:"
python3 --version
"${HOME}/.local/bin/uv" --version 2>/dev/null || uv --version

echo "[verify-python] ok"
