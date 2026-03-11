#!/usr/bin/env bash
# =============================================================================
# 90-verify.sh
# =============================================================================
# Purpose:
#   Run all verification scripts in the checks directory.
#
# Why this exists:
#   The template should be treated like a reproducible asset. A single command
#   that checks the expected tools and services makes iteration much easier.
# =============================================================================
set -Eeuo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

main() {
  echo "[90-verify] running checks..."
  bash "$REPO_ROOT/checks/verify-shell.sh"
  bash "$REPO_ROOT/checks/verify-python.sh"
  bash "$REPO_ROOT/checks/verify-node.sh"
  bash "$REPO_ROOT/checks/verify-postgres.sh"
  bash "$REPO_ROOT/checks/verify-nginx.sh"

  if command -v docker >/dev/null 2>&1; then
    bash "$REPO_ROOT/checks/verify-docker.sh"
  else
    echo "[90-verify] docker not present; skipping docker check."
  fi

  echo "[90-verify] all requested checks completed."
}

main "$@"
