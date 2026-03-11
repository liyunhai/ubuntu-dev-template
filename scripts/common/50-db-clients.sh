#!/usr/bin/env bash
# =============================================================================
# 50-db-clients.sh
# =============================================================================
# Purpose:
#   Install common database client tools without making every database service
#   run locally by default.
#
# Why this split:
#   A reusable dev template should stay reasonably light. Client tools are cheap,
#   while multiple always-on database services increase complexity and memory use.
#
# Official references:
#   - WSL DB guide: https://learn.microsoft.com/en-us/windows/wsl/tutorials/wsl-database
# =============================================================================
set -Eeuo pipefail

main() {
  echo "[50-db-clients] installing database clients..."
  sudo apt update
  sudo apt install -y sqlite3 postgresql-client mysql-client redis-tools

  echo "[50-db-clients] done."
}

main "$@"
