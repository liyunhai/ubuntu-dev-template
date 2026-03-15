#!/usr/bin/env bash
set -euo pipefail

###############################################################################
# 16-yazi.sh
#
# 作用：
#   1. 安装 Yazi 及其常用依赖
#   2. 将模板中的 Yazi 配置同步到 ~/.config/yazi
#   3. 使用 ya 安装 flavor 与插件
#
# 适用环境：
#   - Ubuntu 24.04
#   - WSL Ubuntu 24.04
#   - macOS OrbStack 中的 Ubuntu
#
# 设计原则：
#   - 尽量幂等：重复执行不会破坏已有环境
#   - 尽量保守：已有配置先备份
#   - Yazi/ya 同版本安装，避免插件管理异常
###############################################################################

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"

DOTFILES_YAZI_DIR="${REPO_ROOT}/dotfiles/.config/yazi"
TARGET_YAZI_DIR="${HOME}/.config/yazi"

log() {
  printf '[16-yazi] %s\n' "$*"
}

warn() {
  printf '[16-yazi] WARNING: %s\n' "$*" >&2
}

die() {
  printf '[16-yazi] ERROR: %s\n' "$*" >&2
  exit 1
}

require_command() {
  command -v "$1" >/dev/null 2>&1 || die "required command not found: $1"
}

backup_if_exists() {
  local path="$1"
  if [ -e "$path" ]; then
    local ts
    ts="$(date +%Y%m%d-%H%M%S)"
    local backup="${path}.bak.${ts}"
    cp -a "$path" "$backup"
    log "backed up existing file: ${path} -> ${backup}"
  fi
}

detect_arch_asset() {
  local arch
  arch="$(uname -m)"

  case "$arch" in
    x86_64)
      printf '%s' "yazi-x86_64-unknown-linux-gnu.zip"
      ;;
    aarch64|arm64)
      printf '%s' "yazi-aarch64-unknown-linux-gnu.zip"
      ;;
    *)
      die "unsupported architecture for prebuilt Yazi binary: ${arch}"
      ;;
  esac
}

install_prerequisites() {
  log "installing Yazi prerequisites via apt..."

  sudo apt update
  sudo apt install -y \
    curl \
    unzip \
    fd-find \
    ripgrep \
    fzf \
    zoxide \
    file \
    jq \
    p7zip-full \
    poppler-utils \
    mediainfo
}

install_yazi_binary() {
  if command -v yazi >/dev/null 2>&1 && command -v ya >/dev/null 2>&1; then
    log "yazi and ya already installed, skipping binary installation"
    return 0
  fi

  local asset
  asset="$(detect_arch_asset)"

  local tmpdir
  tmpdir="$(mktemp -d)"

  log "downloading Yazi release asset: ${asset}"
  curl -fL "https://github.com/sxyazi/yazi/releases/latest/download/${asset}" \
    -o "${tmpdir}/yazi.zip"

  log "extracting Yazi release package..."
  unzip -q "${tmpdir}/yazi.zip" -d "${tmpdir}/yazi"

  local extracted_dir
  extracted_dir="$(find "${tmpdir}/yazi" -mindepth 1 -maxdepth 1 -type d | head -n 1)"

  [ -n "${extracted_dir}" ] || die "failed to locate extracted Yazi directory"
  [ -f "${extracted_dir}/yazi" ] || die "missing yazi binary in extracted package"
  [ -f "${extracted_dir}/ya" ] || die "missing ya binary in extracted package"

  log "installing yazi and ya to /usr/local/bin..."
  sudo install -Dm755 "${extracted_dir}/yazi" /usr/local/bin/yazi
  sudo install -Dm755 "${extracted_dir}/ya"   /usr/local/bin/ya

  rm -rf "${tmpdir}"

  log "installed:"
  yazi --version
  ya --version
}

ensure_fd_compat() {
  if command -v fd >/dev/null 2>&1; then
    log "fd command already exists"
    return 0
  fi

  if command -v fdfind >/dev/null 2>&1; then
    mkdir -p "${HOME}/.local/bin"
    ln -sf "$(command -v fdfind)" "${HOME}/.local/bin/fd"
    log "created compatibility symlink: ~/.local/bin/fd -> $(command -v fdfind)"

    case ":$PATH:" in
      *":${HOME}/.local/bin:"*)
        ;;
      *)
        warn "~/.local/bin is not in PATH; add it in your shell config if needed"
        ;;
    esac
  else
    warn "neither fd nor fdfind found; search integration may be degraded"
  fi
}

install_config_files() {
  [ -d "${DOTFILES_YAZI_DIR}" ] || die "template yazi config dir not found: ${DOTFILES_YAZI_DIR}"

  mkdir -p "${TARGET_YAZI_DIR}"

  local file
  for file in yazi.toml keymap.toml init.lua theme.toml package.toml; do
    local src="${DOTFILES_YAZI_DIR}/${file}"
    local dst="${TARGET_YAZI_DIR}/${file}"

    [ -f "${src}" ] || die "missing template file: ${src}"

    if [ -f "${dst}" ] && ! cmp -s "${src}" "${dst}"; then
      backup_if_exists "${dst}"
    fi

    cp "${src}" "${dst}"
    log "installed ${dst}"
  done
}

# install_flavor_and_plugins() {
#   require_command yazi
#   require_command ya

#   log "checking yazi / ya versions..."
#   yazi --version
#   ya --version

#   cd "${TARGET_YAZI_DIR}"

#   log "installing flavor and plugins with ya..."

#   # flavor: 仓库叫 kanagawa.yazi，但 ya 包名用 kanagawa
#   ya pkg add dangooddd/kanagawa || warn "failed to add kanagawa flavor"

#   # 官方插件仓库中的 git 插件
#   ya pkg add yazi-rs/plugins:git || warn "failed to add git plugin"

#   ya pkg install || warn "ya pkg install failed; check network/proxy and rerun later"
# }

install_flavor_and_plugins() {
  require_command yazi
  require_command ya

  log "checking yazi / ya versions..."
  yazi --version
  ya --version

  cd "${TARGET_YAZI_DIR}"

  # 如果 package.toml 已经由模板提供，
  # 那么新机器初始化时最合理的是直接按 package.toml 安装依赖，
  # 而不是再次 ya pkg add。
  if [ -f "${TARGET_YAZI_DIR}/package.toml" ]; then
    log "package.toml found, installing packages from lock file..."
    ya pkg install || warn "ya pkg install failed; check network/proxy and rerun later"
  else
    # 兜底逻辑：如果将来没有 package.toml，再执行 add
    log "package.toml not found, adding default flavor and plugin..."
    ya pkg add dangooddd/kanagawa || warn "failed to add kanagawa flavor"
    ya pkg add yazi-rs/plugins:git || warn "failed to add git plugin"
    ya pkg install || warn "ya pkg install failed; check network/proxy and rerun later"
  fi
}

print_next_steps() {
  cat <<'EOF'
[16-yazi] Yazi installation completed.

Recommended checks:
  1. Verify commands:
       yazi --version
       ya --version
       command -v fd
       command -v fdfind

  2. Start Yazi:
       yazi

  3. If plugin or flavor installation failed:
       cd ~/.config/yazi
       ya pkg install

Notes:
  - This template keeps Yazi light in v1.
  - Image inline preview is not forced yet, to reduce WSL/OrbStack divergence.
EOF
}

main() {
  require_command sudo
  require_command apt
  require_command curl
  require_command unzip

  install_prerequisites
  install_yazi_binary
  ensure_fd_compat
  install_config_files
  install_flavor_and_plugins
  print_next_steps

  log "done"
}

main "$@"