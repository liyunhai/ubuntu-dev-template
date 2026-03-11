#!/usr/bin/env bash
# =============================================================================
# 02-docker-engine.sh
# =============================================================================
# Purpose:
#   Install Docker Engine natively inside WSL Ubuntu 24.04 using Docker's
#   official apt repository.
#
# Official references:
#   - Docker Engine on Ubuntu: https://docs.docker.com/engine/install/ubuntu/
#   - Docker Linux post-install: https://docs.docker.com/engine/install/linux-postinstall/
#
# Why native Docker in WSL:
#   This template intentionally uses Docker Engine inside Ubuntu for WSL.
#
# Assumptions:
#   - systemd is enabled in WSL
#   - you are on Ubuntu 24.04 or another supported release
# =============================================================================
set -Eeuo pipefail

main() {
  echo "[wsl-docker] removing conflicting unofficial packages if present..."
  for pkg in docker.io docker-doc docker-compose docker-compose-v2 podman-docker containerd runc; do
    sudo apt remove -y "$pkg" 2>/dev/null || true
  done

  echo "[wsl-docker] installing repository prerequisites..."
  sudo apt update
  sudo apt install -y ca-certificates curl gnupg
  sudo install -m 0755 -d /etc/apt/keyrings

  if [[ ! -f /etc/apt/keyrings/docker.asc ]]; then
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    sudo chmod a+r /etc/apt/keyrings/docker.gpg
  fi

  local arch codename
  arch="$(dpkg --print-architecture)"
  codename="$(. /etc/os-release && echo "$VERSION_CODENAME")"

  echo "[wsl-docker] configuring apt source..."
  echo \
    "deb [arch=${arch} signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu ${codename} stable" \
    | sudo tee /etc/apt/sources.list.d/docker.list >/dev/null

  echo "[wsl-docker] installing Docker Engine and plugins..."
  sudo apt update
  sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

  echo "[wsl-docker] configuring non-root docker usage..."
  sudo groupadd docker 2>/dev/null || true
  sudo usermod -aG docker "$USER"

  if [[ "$(ps -p 1 -o comm= | tr -d ' ')" == "systemd" ]]; then
    echo "[wsl-docker] enabling docker service under systemd..."
    sudo systemctl enable docker
    sudo systemctl enable containerd
    sudo systemctl restart docker
  else
    echo "[wsl-docker] WARNING: systemd not detected. Docker service enable was skipped."
  fi

  cat <<MSG
[wsl-docker] done.
[wsl-docker] IMPORTANT: log out and back in (or restart WSL) so group membership takes effect.
[wsl-docker] recommended checks after re-login:
  docker version
  docker compose version
  docker run hello-world
MSG
}

main "$@"
