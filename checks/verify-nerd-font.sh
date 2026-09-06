#!/usr/bin/env bash
set -Eeuo pipefail

FONT_FAMILY="JetBrainsMono Nerd Font"

echo "[verify-nerd-font] checking fontconfig..."
command -v fc-match >/dev/null

matched_family="$(fc-match -f '%{family[0]}' "$FONT_FAMILY")"
[[ "$matched_family" == "$FONT_FAMILY" ]] || {
  printf '[verify-nerd-font] expected %s, selected %s\n' "$FONT_FAMILY" "$matched_family" >&2
  exit 1
}

fc-match -f '[verify-nerd-font] %{family[0]} %{style[0]}: %{file}\n' "$FONT_FAMILY"
echo "[verify-nerd-font] ok"
