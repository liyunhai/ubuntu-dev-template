#!/usr/bin/env bash
# =============================================================================
# 30-python.sh
# =============================================================================
# Purpose:
#   Install the Python development toolchain:
#   - system python
#   - python3-venv
#   - python3-pip
#   - pipx
#   - uv
#   - common quality tools
#
# Why this stack:
#   For a reusable dev template, `venv + pipx + uv` is lighter and simpler than
#   making Conda the default.
#
# Official references:
#   - Python venv: https://docs.python.org/3/library/venv.html
#   - uv install: https://docs.astral.sh/uv/getting-started/installation/
#   - pre-commit: https://pre-commit.com/
# =============================================================================
set -Eeuo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

main() {
  echo "[30-python] installing python packages from apt..."
  sudo apt update
  sudo apt install -y python3 python3-venv python3-pip pipx

  echo "[30-python] ensuring pip config exists..."
  mkdir -p "$HOME/.config/pip"
  cp -f "$REPO_ROOT/dotfiles/.config/pip/pip.conf" "$HOME/.config/pip/pip.conf"

  echo "[30-python] ensuring pipx path..."
  python3 -m pipx ensurepath || true

  if ! command -v uv >/dev/null 2>&1; then
    echo "[30-python] installing uv via official installer..."
    curl -LsSf https://astral.sh/uv/install.sh | sh
  else
    echo "[30-python] uv already present."
  fi

  export PATH="$HOME/.local/bin:$PATH"

  echo "[30-python] installing python dev tools with pipx..."
  pipx install --force ruff || true
  pipx install --force black || true
  pipx install --force pytest || true
  pipx install --force pre-commit || true

  cat <<MSG
[30-python] done.
[30-python] recommended checks:
  python3 --version
  uv --version
  pipx list
MSG
}

main "$@"
