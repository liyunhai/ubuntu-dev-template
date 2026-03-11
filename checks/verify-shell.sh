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

echo "[verify-shell] ok"
