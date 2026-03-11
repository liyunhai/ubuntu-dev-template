#!/usr/bin/env bash
set -Eeuo pipefail

echo "[verify-postgres] checking PostgreSQL client..."
command -v psql >/dev/null
psql --version

if command -v systemctl >/dev/null 2>&1 && [[ "$(ps -p 1 -o comm= | tr -d ' ')" == "systemd" ]]; then
  echo "[verify-postgres] checking PostgreSQL service status..."
  sudo systemctl is-enabled postgresql >/dev/null 2>&1 || true
  sudo systemctl is-active postgresql >/dev/null 2>&1 || true
fi

echo "[verify-postgres] ok"
