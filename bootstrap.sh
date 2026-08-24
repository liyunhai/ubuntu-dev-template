#!/usr/bin/env bash
set -Eeuo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DRY_RUN=false
CURRENT_STEP="startup"

log() { printf '[bootstrap] %s\n' "$*"; }
die() { printf '[bootstrap] ERROR: %s\n' "$*" >&2; exit 1; }

usage() {
  cat <<'EOF'
Usage: ./bootstrap.sh [--dry-run]

Installs the complete Ubuntu development environment. Platform integration is
detected automatically for regular Ubuntu, WSL, and OrbStack machines.

Options:
  --dry-run  Print the scripts in execution order without changing the system.
  -h, --help Show this help.
EOF
}

detect_platform() {
  if grep -qi microsoft /proc/version 2>/dev/null; then
    printf '%s' 'wsl'
  elif [[ "$(uname -r)" == *[Oo]rbstack* ]] || [[ -e /opt/orbstack-guest ]]; then
    printf '%s' 'orbstack'
  else
    printf '%s' 'ubuntu'
  fi
}

check_host() {
  [[ "$EUID" -ne 0 ]] || die "run as your normal user, not with sudo"
  [[ -r /etc/os-release ]] || die "/etc/os-release not found"
  # shellcheck disable=SC1091
  source /etc/os-release
  [[ "${ID:-}" == "ubuntu" ]] || die "Ubuntu is required (detected: ${ID:-unknown})"
}

run_script() {
  local relative_path="$1"
  CURRENT_STEP="$relative_path"
  [[ -f "${REPO_ROOT}/${relative_path}" ]] || die "script not found: $relative_path"
  if "$DRY_RUN"; then
    printf '  %s\n' "$relative_path"
  else
    log "running ${relative_path}"
    bash "${REPO_ROOT}/${relative_path}"
  fi
}

prepare_wsl() {
  run_script scripts/wsl/00-wsl-preflight.sh
  if ! "$DRY_RUN" && [[ "$(ps -p 1 -o comm= | tr -d ' ')" != "systemd" ]]; then
    run_script scripts/wsl/01-write-wslconf.sh
    log "WSL must restart before installation can continue."
    log "Run 'wsl --shutdown' from Windows, reopen Ubuntu, then rerun ./bootstrap.sh."
    exit 2
  fi
}

load_installed_tool_paths() {
  export PATH="${HOME}/.local/bin:${HOME}/bin:${PATH}"
  export NVM_DIR="${HOME}/.nvm"
  # shellcheck disable=SC1091
  [[ -s "${NVM_DIR}/nvm.sh" ]] && source "${NVM_DIR}/nvm.sh"
}

main() {
  while (($#)); do
    case "$1" in
      --dry-run) DRY_RUN=true ;;
      -h|--help) usage; exit 0 ;;
      *) die "unknown option: $1" ;;
    esac
    shift
  done

  check_host
  local platform
  platform="$(detect_platform)"
  log "detected platform: $platform"
  "$DRY_RUN" || sudo -v

  case "$platform" in
    wsl) prepare_wsl ;;
    orbstack)
      run_script scripts/orbstack/00-orb-preflight.sh
      run_script scripts/orbstack/01-machine-setup.sh
      ;;
  esac

  run_script scripts/common/00-base.sh
  run_script scripts/common/10-shell.sh
  run_script scripts/common/15-tmux.sh
  run_script scripts/common/16-zellij.sh
  run_script scripts/common/17-herdr.sh
  run_script scripts/common/18-yazi.sh
  run_script scripts/common/20-direnv.sh
  run_script scripts/common/30-python.sh
  run_script scripts/common/40-node.sh
  run_script scripts/common/50-db-clients.sh
  run_script scripts/common/60-postgres.sh
  run_script scripts/common/70-nginx.sh

  if [[ "$platform" == "orbstack" ]]; then
    log "using OrbStack's built-in Docker engine"
  else
    run_script scripts/common/75-docker-engine.sh
  fi

  run_script scripts/common/80-devtools.sh

  if "$DRY_RUN"; then
    run_script scripts/common/90-verify.sh
  else
    load_installed_tool_paths
    run_script scripts/common/90-verify.sh
    log "installation complete; open a new login session to refresh shell and Docker group membership"
  fi
}

trap 'printf "[bootstrap] ERROR: failed at %s (line %s)\n" "$CURRENT_STEP" "$LINENO" >&2' ERR
main "$@"
