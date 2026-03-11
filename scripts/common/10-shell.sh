#!/usr/bin/env bash
# =============================================================================
# 10-shell.sh
# =============================================================================
# Purpose:
#   Install zsh, Oh My Zsh, Powerlevel10k, and common zsh plugins.
#
# Why this exists:
#   We want the interactive shell experience to be nearly identical between
#   WSL Ubuntu and OrbStack Ubuntu.
#
# Official references:
#   - Oh My Zsh: https://ohmyz.sh/
#   - Nerd Fonts: https://www.nerdfonts.com/
#
# Important:
#   - Nerd Fonts must be installed on the host terminal environment, not inside
#     Ubuntu itself.
#   - This script does not overwrite your .zshrc automatically unless you choose
#     to copy the provided dotfile separately.
# =============================================================================
set -Eeuo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
ZSH_CUSTOM_DIR="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

clone_or_update() {
  local repo_url="$1"
  local target_dir="$2"

  if [[ -d "$target_dir/.git" ]]; then
    echo "[10-shell] updating $(basename "$target_dir")..."
    git -C "$target_dir" pull --ff-only
  else
    echo "[10-shell] cloning $(basename "$target_dir")..."
    git clone --depth=1 "$repo_url" "$target_dir"
  fi
}

main() {
  echo "[10-shell] installing zsh and shell helpers..."
  sudo apt update
  sudo apt install -y zsh git curl fzf

  if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
    echo "[10-shell] installing Oh My Zsh..."
    RUNZSH=no CHSH=no sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
  else
    echo "[10-shell] Oh My Zsh already installed."
  fi

  mkdir -p "$ZSH_CUSTOM_DIR/themes" "$ZSH_CUSTOM_DIR/plugins"

  clone_or_update https://github.com/romkatv/powerlevel10k.git \
    "$ZSH_CUSTOM_DIR/themes/powerlevel10k"
  clone_or_update https://github.com/zsh-users/zsh-autosuggestions.git \
    "$ZSH_CUSTOM_DIR/plugins/zsh-autosuggestions"
  clone_or_update https://github.com/zsh-users/zsh-syntax-highlighting.git \
    "$ZSH_CUSTOM_DIR/plugins/zsh-syntax-highlighting"
  clone_or_update https://github.com/zsh-users/zsh-completions.git \
    "$ZSH_CUSTOM_DIR/plugins/zsh-completions"

  echo "[10-shell] installing dotfiles into ~/.config/shell ..."
  mkdir -p "$HOME/.config/shell"
  cp -f "$REPO_ROOT/dotfiles/shell/aliases.zsh" "$HOME/.config/shell/aliases.zsh"
  cp -f "$REPO_ROOT/dotfiles/shell/exports.zsh" "$HOME/.config/shell/exports.zsh"
  cp -f "$REPO_ROOT/dotfiles/shell/functions.zsh" "$HOME/.config/shell/functions.zsh"

  if [[ ! -f "$HOME/.zshrc" ]]; then
    cp "$REPO_ROOT/dotfiles/.zshrc" "$HOME/.zshrc"
    echo "[10-shell] installed starter ~/.zshrc"
  else
    echo "[10-shell] ~/.zshrc already exists; not overwriting."
    echo "[10-shell] compare with: $REPO_ROOT/dotfiles/.zshrc"
  fi

  if [[ ! -f "$HOME/.p10k.zsh" ]]; then
    cp "$REPO_ROOT/dotfiles/.p10k.zsh" "$HOME/.p10k.zsh"
  fi

  if [[ "$(getent passwd "$USER" | cut -d: -f7)" != "$(command -v zsh)" ]]; then
    echo "[10-shell] changing default shell to zsh..."
    chsh -s "$(command -v zsh)"
  fi

  cat <<MSG
[10-shell] done.
[10-shell] next steps:
  1. Install a Nerd Font on the host terminal.
  2. Start a new terminal session.
  3. Optionally run: p10k configure
MSG
}

main "$@"
