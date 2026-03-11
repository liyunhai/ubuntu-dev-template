#!/usr/bin/env bash
# =============================================================================
# 00-base.sh
# =============================================================================
# Purpose:
#   Install the baseline packages that almost every later layer depends on.
#
# Why this exists:
#   This script creates a sane Ubuntu 24.04 base for both WSL and OrbStack
#   machines. It intentionally avoids anything host-specific.
#
# Official references:
#   - Git on Linux: https://git-scm.com/install/linux
#   - WSL file/perf guidance: https://learn.microsoft.com/en-us/windows/wsl/filesystems
#
# Notes:
#   - Safe to re-run.
#   - Installs only broadly useful packages.
#   - Does not modify shell config or service config.
# =============================================================================
set -Eeuo pipefail

PACKAGES=(
  build-essential
  ca-certificates
  curl
  wget
  gnupg
  software-properties-common
  unzip
  zip
  jq
  tree
  ripgrep
  fd-find
  fzf
  tmux
  htop
  git
  openssh-client
  make
  pkg-config
  sqlite3
)

main() {
  echo "[00-base] updating apt metadata..."
  sudo apt update

  echo "[00-base] installing base packages..."
  sudo apt install -y "${PACKAGES[@]}"

  echo "[00-base] ensuring workspace layout exists..."
  mkdir -p "$HOME/workspace"/{apps,libs,infra,playground}
  mkdir -p "$HOME/bin"
  mkdir -p "$HOME/.local/bin"

  echo "[00-base] done."
}

main "$@"
