#!/usr/bin/env bash
set -Eeuo pipefail

echo "[verify-docker] checking docker..."
command -v docker >/dev/null
docker version >/dev/null

echo "[verify-docker] checking docker compose..."
docker compose version >/dev/null

echo "[verify-docker] ok"
