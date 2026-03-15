#!/usr/bin/env bash
set -euo pipefail

###############################################################################
# 90-verify.sh
#
# 作用：
#   统一执行模板中的所有验证脚本。
#
# 说明：
#   - 每个验证脚本负责一个模块
#   - 本脚本只负责按顺序调用，并给出整体结果
#   - 如果其中任何一个脚本返回非 0，本脚本会直接失败退出
###############################################################################

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"
CHECKS_DIR="${REPO_ROOT}/checks"

log() {
  printf '[90-verify] %s\n' "$*"
}

run_check() {
  local check_script="$1"

  if [ ! -x "${check_script}" ]; then
    log "making executable: ${check_script}"
    chmod +x "${check_script}"
  fi

  "${check_script}"
}

main() {
  log "running checks..."

  run_check "${CHECKS_DIR}/verify-shell.sh"
  run_check "${CHECKS_DIR}/verify-tmux.sh"
  run_check "${CHECKS_DIR}/verify-yazi.sh"
  run_check "${CHECKS_DIR}/verify-python.sh"
  run_check "${CHECKS_DIR}/verify-node.sh"
  run_check "${CHECKS_DIR}/verify-postgres.sh"
  run_check "${CHECKS_DIR}/verify-nginx.sh"
  run_check "${CHECKS_DIR}/verify-docker.sh"

  log "all checks passed"
}

main "$@"
