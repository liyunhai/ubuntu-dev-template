#!/usr/bin/env bash
# =============================================================================
# 60-postgres.sh
# =============================================================================
# Purpose:
#   Install PostgreSQL natively on Ubuntu.
#
# Why PostgreSQL is native here:
#   For a general-purpose developer template, PostgreSQL is a good default local
#   database to keep available at all times.
#
# Official references:
#   - PostgreSQL on Ubuntu: https://www.postgresql.org/download/linux/ubuntu/
#
# Notes:
#   - On systemd-enabled systems, the service typically starts automatically.
#   - On WSL, this behaves best when systemd is enabled.
# =============================================================================
set -Eeuo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
# shellcheck source=../lib/os.sh
source "${REPO_ROOT}/scripts/lib/os.sh"

main() {
  echo "[60-postgres] installing PostgreSQL..."
  sudo apt update
  sudo apt install -y postgresql postgresql-client

  if systemd_is_active; then
    echo "[60-postgres] enabling PostgreSQL service..."
    sudo systemctl enable postgresql || true
    sudo systemctl start postgresql || true
    sudo systemctl status postgresql --no-pager || true
  else
    echo "[60-postgres] systemd not detected; skipping service enable/start."
  fi

  cat <<MSG
[60-postgres] done.
[60-postgres] to create a user/db manually, use the postgres admin account.
MSG
}

main "$@"
