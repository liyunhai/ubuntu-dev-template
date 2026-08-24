#!/usr/bin/env bash
set -Eeuo pipefail

echo "[verify-docker] checking docker..."
command -v docker >/dev/null
if docker version >/dev/null 2>&1; then
  echo "[verify-docker] Docker daemon is available to the current session."
elif command -v sudo >/dev/null 2>&1 && sudo docker version >/dev/null; then
  echo "[verify-docker] Docker is running; open a new login session to activate docker-group membership."
else
  echo "[verify-docker] Docker daemon is unavailable." >&2
  exit 1
fi

echo "[verify-docker] checking docker compose..."
docker compose version >/dev/null

echo "[verify-docker] ok"
