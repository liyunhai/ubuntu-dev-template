#!/usr/bin/env bash
set -Eeuo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
# shellcheck source=../lib/os.sh
source "${REPO_ROOT}/scripts/lib/os.sh"

DOCKER_KEYRING="/etc/apt/keyrings/docker.asc"
DOCKER_SOURCE="/etc/apt/sources.list.d/docker.list"
ALLOW_DOCKER_PACKAGE_REPLACEMENT="${ALLOW_DOCKER_PACKAGE_REPLACEMENT:-false}"

log() { printf '[75-docker] %s\n' "$*"; }
die() { printf '[75-docker] ERROR: %s\n' "$*" >&2; exit 1; }
require_command() { command -v "$1" >/dev/null 2>&1 || die "required command not found: $1 (run 00-base.sh first)"; }

check_environment() {
  [[ "$EUID" -ne 0 ]] || die "run this script as your normal user, not with sudo"
  if [[ "$(uname -r)" == *[Oo]rbstack* ]] || [[ -e /opt/orbstack-guest ]]; then
    die "OrbStack detected; use its built-in Docker engine"
  fi
  require_supported_ubuntu_family || exit 1
  systemd_is_active || die "systemd is not active; enable it before installing Docker Engine"
}

remove_conflicting_packages() {
  local package status
  local -a installed=()
  for package in docker.io docker-doc docker-compose docker-compose-v2 podman-docker containerd runc; do
    status="$(dpkg-query -W -f='${db:Status-Status}' "$package" 2>/dev/null || true)"
    [[ "$status" == installed ]] && installed+=("$package")
  done

  ((${#installed[@]})) || return 0
  if ! "$ALLOW_DOCKER_PACKAGE_REPLACEMENT"; then
    die "conflicting packages are installed: ${installed[*]}. Review them, then rerun bootstrap with --replace-docker-packages if Docker CE should replace them"
  fi

  log "removing explicitly approved conflicting packages: ${installed[*]}"
  for package in "${installed[@]}"; do
    sudo apt remove -y "$package"
  done
}

configure_repository() (
  local tmpdir key_file source_file arch codename
  tmpdir="$(mktemp -d)"
  trap 'rm -rf -- "$tmpdir"' EXIT
  key_file="${tmpdir}/docker.asc"
  source_file="${tmpdir}/docker.list"
  arch="$(dpkg --print-architecture)"

  load_os_release
  codename="$UBUNTU_BASE_CODENAME"

  log "installing Docker's official apt signing key..."
  curl -fsSL --retry 3 https://download.docker.com/linux/ubuntu/gpg -o "$key_file"
  sudo install -d -m 0755 /etc/apt/keyrings
  sudo install -m 0644 "$key_file" "$DOCKER_KEYRING"

  printf 'deb [arch=%s signed-by=%s] https://download.docker.com/linux/ubuntu %s stable\n' \
    "$arch" "$DOCKER_KEYRING" "$codename" >"$source_file"
  sudo install -m 0644 "$source_file" "$DOCKER_SOURCE"
)

install_docker() {
  log "installing Docker Engine, Buildx, and Compose..."
  sudo apt update
  sudo apt install -y \
    docker-ce \
    docker-ce-cli \
    containerd.io \
    docker-buildx-plugin \
    docker-compose-plugin \
    docker-ce-rootless-extras
}

configure_service() {
  log "enabling Docker services..."
  sudo systemctl enable --now containerd docker

  if ! getent group docker >/dev/null; then
    sudo groupadd docker
  fi
  sudo usermod -aG docker "$USER"
}

verify_installation() {
  sudo docker version >/dev/null
  docker compose version
  log "Docker Engine is running. Group membership takes effect after a new login session."
}

main() {
  require_command sudo
  require_command apt
  require_command curl
  require_command dpkg
  require_command dpkg-query
  require_command systemctl
  check_environment

  sudo -v
  sudo apt update
  sudo apt install -y ca-certificates curl
  remove_conflicting_packages
  configure_repository
  install_docker
  configure_service
  verify_installation

  cat <<'EOF'
[75-docker] done.
[75-docker] Open a new login session, then check:
  docker version
  docker compose version
  docker run --rm hello-world
EOF
}

main "$@"
