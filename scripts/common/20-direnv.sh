#!/usr/bin/env bash
# =============================================================================
# 20-direnv.sh
# =============================================================================
# Purpose:
#   Install direnv and its config, then ensure shell hook support is present.
#
# Why direnv:
#   direnv provides per-directory environment loading. It is ideal for keeping
#   project-specific PATH additions, secrets, or runtime toggles out of your
#   global shell environment.
#
# Official references:
#   - direnv install and hooks: https://direnv.net/docs/installation.html
# =============================================================================
set -Eeuo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

main() {
  echo "[20-direnv] installing direnv..."
  sudo apt update
  sudo apt install -y direnv

  echo "[20-direnv] installing config..."
  mkdir -p "$HOME/.config/direnv"
  cp -f "$REPO_ROOT/dotfiles/.config/direnv/direnv.toml" "$HOME/.config/direnv/direnv.toml"

  if ! grep -q 'direnv hook zsh' "$HOME/.zshrc" 2>/dev/null; then
    cat >> "$HOME/.zshrc" <<'ZEOF'

# direnv shell integration
if command -v direnv >/dev/null 2>&1; then
  eval "$(direnv hook zsh)"
fi
ZEOF
  fi

  echo "[20-direnv] done. Run 'source ~/.zshrc' or open a new shell."
}

main "$@"
