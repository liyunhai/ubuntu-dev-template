#!/usr/bin/env bash
set -euo pipefail

log() {
  printf '[verify-yazi] %s\n' "$*"
}

die() {
  printf '[verify-yazi] ERROR: %s\n' "$*" >&2
  exit 1
}

require_cmd() {
  command -v "$1" >/dev/null 2>&1 || die "required command not found: $1"
}

log "checking yazi / ya..."
require_cmd yazi
require_cmd ya

log "versions:"
yazi --version
ya --version

log "checking config directory..."
[ -d "${HOME}/.config/yazi" ] || die "~/.config/yazi not found"

for file in yazi.toml keymap.toml init.lua theme.toml package.toml; do
  [ -f "${HOME}/.config/yazi/${file}" ] || die "missing config file: ~/.config/yazi/${file}"
done

log "checking common dependencies..."
require_cmd file
require_cmd jq
require_cmd rg
require_cmd fzf
require_cmd zoxide

if command -v fd >/dev/null 2>&1; then
  log "fd found"
elif command -v fdfind >/dev/null 2>&1; then
  log "fdfind found"
else
  die "neither fd nor fdfind found"
fi

log "checking optional preview helpers..."
command -v pdftoppm >/dev/null 2>&1 || log "pdftoppm not found (optional)"
command -v mediainfo >/dev/null 2>&1 || log "mediainfo not found (optional)"
command -v 7z >/dev/null 2>&1 || log "7z not found (optional)"

log "ok"
