#!/usr/bin/env bash
set -Eeuo pipefail

echo "[verify-nginx] checking nginx..."
command -v nginx >/dev/null
nginx -v
sudo nginx -t >/dev/null

echo "[verify-nginx] ok"
