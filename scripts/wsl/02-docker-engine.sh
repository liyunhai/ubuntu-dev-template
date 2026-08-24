#!/usr/bin/env bash
set -Eeuo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"

if ! grep -qi microsoft /proc/version; then
  echo "[wsl-docker] ERROR: this compatibility entry point is for WSL only." >&2
  echo "[wsl-docker] Use scripts/common/75-docker-engine.sh on a regular Ubuntu VM." >&2
  exit 1
fi

exec "${REPO_ROOT}/scripts/common/75-docker-engine.sh" "$@"
