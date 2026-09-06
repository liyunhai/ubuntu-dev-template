#!/usr/bin/env bash
set -Eeuo pipefail

echo "[verify-shell] checking zsh..."
command -v zsh >/dev/null

echo "[verify-shell] checking Oh My Zsh directory..."
[[ -d "$HOME/.oh-my-zsh" ]]

echo "[verify-shell] checking helper shell files..."
[[ -f "$HOME/.config/shell/aliases.zsh" ]]
[[ -f "$HOME/.config/shell/exports.zsh" ]]
[[ -f "$HOME/.config/shell/functions.zsh" ]]

echo "[verify-shell] checking interactive zsh PATH..."
if ! zsh -ic '[[ ":$PATH:" == *":$HOME/.local/bin:"* ]]' \
  </dev/null >/dev/null 2>&1; then
  echo "[verify-shell] ~/.local/bin is missing from interactive zsh PATH" >&2
  exit 1
fi

echo "[verify-shell] ok"
