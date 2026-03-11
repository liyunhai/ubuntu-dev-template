#!/usr/bin/env bash
set -Eeuo pipefail

echo "[verify-node] checking node stack..."
command -v node >/dev/null
command -v npm >/dev/null
command -v pnpm >/dev/null

echo "[verify-node] versions:"
node -v
npm -v
pnpm -v

echo "[verify-node] ok"
