#!/usr/bin/env bash
# =============================================================================
# 00-wsl-preflight.sh
# =============================================================================
# Purpose:
#   Validate that we are really inside WSL and print important state before
#   applying WSL-specific configuration.
#
# Official references:
#   - WSL systemd: https://learn.microsoft.com/en-us/windows/wsl/systemd
#   - WSL config: https://learn.microsoft.com/en-us/windows/wsl/wsl-config
# =============================================================================
set -Eeuo pipefail

main() {
  if ! grep -qi microsoft /proc/version; then
    echo "[wsl-preflight] This does not appear to be a WSL environment." >&2
    exit 1
  fi

  echo "[wsl-preflight] WSL environment detected."
  echo "[wsl-preflight] kernel: $(uname -r)"
  echo "[wsl-preflight] init process: $(ps -p 1 -o comm= | tr -d ' ')"

  cat <<MSG
[wsl-preflight] reminders:
  - /etc/wsl.conf controls distro-level behavior
  - %UserProfile%\\.wslconfig controls global WSL VM settings
  - after changes, run: wsl --shutdown   (from Windows)
MSG
}

main "$@"
