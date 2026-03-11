#!/usr/bin/env bash
# =============================================================================
# 01-machine-setup.sh
# =============================================================================
# Purpose:
#   Apply lightweight Ubuntu-machine setup steps that are useful on OrbStack.
#
# Notes:
#   The common scripts do almost all real work. This script exists mainly to
#   document the intended OrbStack-specific behavior.
# =============================================================================
set -Eeuo pipefail

main() {
  echo "[orb-machine-setup] ensuring workspace directories exist..."
  mkdir -p "$HOME/workspace"/{apps,libs,infra,playground}

  echo "[orb-machine-setup] done."
  echo "[orb-machine-setup] use OrbStack host-side Docker/containers; do not install another Docker Engine in this machine unless you have a very specific reason."
}

main "$@"
