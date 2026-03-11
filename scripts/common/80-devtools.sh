#!/usr/bin/env bash
# =============================================================================
# 80-devtools.sh
# =============================================================================
# Purpose:
#   Install engineering quality-of-life tools that are useful across many
#   projects and languages.
#
# Why here:
#   These tools are valuable, but they are not needed before the core runtime,
#   shell, and service layers are ready.
#
# Official references:
#   - pre-commit: https://pre-commit.com/
# =============================================================================
set -Eeuo pipefail

main() {
  echo "[80-devtools] installing CLI quality tools..."
  sudo apt update
  sudo apt install -y shellcheck yamllint shfmt gh

  export PATH="$HOME/.local/bin:$PATH"
  if command -v pipx >/dev/null 2>&1; then
    pipx install --force pre-commit || true
  fi

  echo "[80-devtools] done."
}

main "$@"
