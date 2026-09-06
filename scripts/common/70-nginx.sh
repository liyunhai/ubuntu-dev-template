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
# shellcheck source=../lib/os.sh
source "${REPO_ROOT}/scripts/lib/os.sh"
# shellcheck source=../lib/config.sh
source "${REPO_ROOT}/scripts/lib/config.sh"

main() {
  echo "[70-nginx] installing nginx..."
  sudo apt update
  sudo apt install -y nginx

  echo "[70-nginx] installing project nginx templates under ~/workspace/infra/nginx-templates..."
  local template
  for template in "$REPO_ROOT/templates/nginx/"*.conf; do
    install_config_file "$template" "$HOME/workspace/infra/nginx-templates/$(basename "$template")"
  done

  if systemd_is_active; then
    sudo systemctl enable nginx || true
    sudo systemctl start nginx || true
  fi

  echo "[70-nginx] validating nginx config..."
  sudo nginx -t

  echo "[70-nginx] done."
}

main "$@"
