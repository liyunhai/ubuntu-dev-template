#!/usr/bin/env bash
set -euo pipefail

###############################################################################
# verify-tmux.sh
#
# 作用：
#   验证 tmux 及其基础配置是否已正确安装。
#
# 检查内容：
#   1. tmux 命令是否存在
#   2. ~/.tmux.conf 是否存在
#   3. TPM 是否存在
#   4. tmux 版本是否可输出
#
# 说明：
#   - 这里不强制要求插件已经安装完成，因为插件安装通常需要：
#       进入 tmux 会话后，按 Prefix + I
#   - 所以本脚本只验证“tmux 基础设施是否就绪”
###############################################################################

log() {
  printf '[verify-tmux] %s\n' "$*"
}

die() {
  printf '[verify-tmux] ERROR: %s\n' "$*" >&2
  exit 1
}

log "checking tmux command..."
command -v tmux >/dev/null 2>&1 || die "tmux command not found"

log "checking ~/.tmux.conf..."
[ -f "${HOME}/.tmux.conf" ] || die "~/.tmux.conf not found"

log "checking TPM..."
[ -d "${HOME}/.tmux/plugins/tpm" ] || die "TPM not found at ~/.tmux/plugins/tpm"

log "checking tmux version..."
tmux -V

log "checking tmux config syntax by starting a detached test session..."
# 说明：
# - tmux 没有单独的 “lint 配置” 命令
# - 最简单的方式之一是尝试启动一个 detached session
# - 如果配置存在严重语法问题，tmux 启动通常会失败
TEST_SESSION="verify-tmux-$$"
tmux -f "${HOME}/.tmux.conf" new-session -d -s "${TEST_SESSION}" >/dev/null 2>&1 || \
  die "failed to start tmux with ~/.tmux.conf; config may contain errors"

tmux kill-session -t "${TEST_SESSION}" >/dev/null 2>&1 || true

log "ok"
