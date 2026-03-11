#!/usr/bin/env bash
# =============================================================================
# 70-nginx.sh
# =============================================================================
# Purpose:
#   Install nginx and drop example server-block templates.
#
# Why nginx:
#   nginx is a strong default reverse proxy and static server for local dev and
#   deployment simulation.
#
# Official references:
#   - Ubuntu nginx install: https://ubuntu.com/server/docs/how-to/web-services/install-nginx/
#   - Ubuntu nginx config: https://ubuntu.com/server/docs/how-to/web-services/configure-nginx/
# =============================================================================
set -Eeuo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

main() {
  echo "[70-nginx] installing nginx..."
  sudo apt update
  sudo apt install -y nginx

  echo "[70-nginx] installing project nginx templates under ~/workspace/infra/nginx-templates..."
  mkdir -p "$HOME/workspace/infra/nginx-templates"
  cp -f "$REPO_ROOT/templates/nginx/"*.conf "$HOME/workspace/infra/nginx-templates/"

  if command -v systemctl >/dev/null 2>&1 && [[ "$(ps -p 1 -o comm= | tr -d ' ')" == "systemd" ]]; then
    sudo systemctl enable nginx || true
    sudo systemctl start nginx || true
  fi

  echo "[70-nginx] validating nginx config..."
  sudo nginx -t

  echo "[70-nginx] done."
}

main "$@"
