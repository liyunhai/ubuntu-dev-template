#!/usr/bin/env bash

# Shared Ubuntu-family distribution helpers. Call load_os_release before using
# OS_ID, OS_NAME, or UBUNTU_BASE_CODENAME.

load_os_release() {
  local os_release_file="${OS_RELEASE_FILE:-/etc/os-release}"
  local ID="" PRETTY_NAME="" VERSION_CODENAME="" UBUNTU_CODENAME=""

  [[ -r "$os_release_file" ]] || {
    printf '[os] ERROR: OS release file not found: %s\n' "$os_release_file" >&2
    return 1
  }

  # shellcheck disable=SC1091
  source "$os_release_file"
  OS_ID="${ID:-unknown}"
  OS_NAME="${PRETTY_NAME:-$OS_ID}"

  case "$OS_ID" in
    ubuntu)
      UBUNTU_BASE_CODENAME="${VERSION_CODENAME:-}"
      ;;
    linuxmint)
      UBUNTU_BASE_CODENAME="${UBUNTU_CODENAME:-}"
      ;;
    *)
      UBUNTU_BASE_CODENAME=""
      ;;
  esac

  export OS_ID OS_NAME UBUNTU_BASE_CODENAME
}

require_supported_ubuntu_family() {
  load_os_release || return 1
  case "$OS_ID" in
    ubuntu|linuxmint) ;;
    *)
      printf '[os] ERROR: Ubuntu or Linux Mint is required (detected: %s)\n' "$OS_NAME" >&2
      return 1
      ;;
  esac

  [[ -n "$UBUNTU_BASE_CODENAME" ]] || {
    printf '[os] ERROR: unable to determine the Ubuntu base codename for %s\n' "$OS_NAME" >&2
    return 1
  }
}

default_install_profile() {
  load_os_release || return 1
  case "$OS_ID" in
    linuxmint) printf '%s' desktop ;;
    *) printf '%s' server ;;
  esac
}

systemd_is_active() {
  command -v systemctl >/dev/null 2>&1 \
    && [[ -d /run/systemd/system ]] \
    && systemctl show-environment >/dev/null 2>&1
}
