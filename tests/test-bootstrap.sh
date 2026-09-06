#!/usr/bin/env bash
set -Eeuo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TMP_DIR="$(mktemp -d)"
trap 'rm -rf -- "$TMP_DIR"' EXIT

fail() {
  printf '[test-bootstrap] ERROR: %s\n' "$*" >&2
  exit 1
}

assert_contains() {
  local text="$1" expected="$2"
  grep -Fq -- "$expected" <<<"$text" || fail "expected output to contain: $expected"
}

assert_not_contains() {
  local text="$1" unexpected="$2"
  if grep -Fq -- "$unexpected" <<<"$text"; then
    fail "expected output not to contain: $unexpected"
  fi
}

write_os_fixtures() {
  printf '%s\n' \
    'ID=linuxmint' \
    'PRETTY_NAME="Test Linux Mint"' \
    'VERSION_CODENAME=testmint' \
    'UBUNTU_CODENAME=noble' >"${TMP_DIR}/mint-os-release"
  printf '%s\n' \
    'ID=ubuntu' \
    'PRETTY_NAME="Test Ubuntu"' \
    'VERSION_CODENAME=resolute' >"${TMP_DIR}/ubuntu-os-release"
  printf '%s\n' \
    'ID=linuxmint' \
    'PRETTY_NAME="Test Linux Mint 23"' \
    'VERSION_CODENAME=testmint23' \
    'UBUNTU_CODENAME=resolute' >"${TMP_DIR}/mint23-os-release"
}

test_mint_defaults() {
  local plan
  plan="$(OS_RELEASE_FILE="${TMP_DIR}/mint-os-release" "${REPO_ROOT}/bootstrap.sh" --dry-run)"
  assert_contains "$plan" 'Ubuntu base: noble'
  assert_contains "$plan" 'install profile: desktop'
  assert_contains "$plan" 'scripts/common/12-nerd-font.sh'
  assert_not_contains "$plan" 'scripts/common/60-postgres.sh'
  assert_not_contains "$plan" 'scripts/common/70-nginx.sh'
  assert_not_contains "$plan" 'scripts/common/75-docker-engine.sh'
}

test_ubuntu_defaults() {
  local plan
  plan="$(OS_RELEASE_FILE="${TMP_DIR}/ubuntu-os-release" "${REPO_ROOT}/bootstrap.sh" --dry-run)"
  assert_contains "$plan" 'Ubuntu base: resolute'
  assert_contains "$plan" 'install profile: server'
  assert_not_contains "$plan" 'scripts/common/12-nerd-font.sh'
  assert_contains "$plan" 'scripts/common/60-postgres.sh'
  assert_contains "$plan" 'scripts/common/70-nginx.sh'
  assert_contains "$plan" 'scripts/common/75-docker-engine.sh'
}

test_mint_23_base() {
  local plan
  plan="$(OS_RELEASE_FILE="${TMP_DIR}/mint23-os-release" "${REPO_ROOT}/bootstrap.sh" --dry-run)"
  assert_contains "$plan" 'Ubuntu base: resolute'
  assert_contains "$plan" 'install profile: desktop'
}

test_module_overrides() {
  local plan
  plan="$(OS_RELEASE_FILE="${TMP_DIR}/mint-os-release" "${REPO_ROOT}/bootstrap.sh" \
    --dry-run --with docker,postgres --skip shell,herdr)"
  assert_contains "$plan" 'scripts/common/60-postgres.sh'
  assert_contains "$plan" 'scripts/common/75-docker-engine.sh'
  assert_not_contains "$plan" 'scripts/common/10-shell.sh'
  assert_not_contains "$plan" 'scripts/common/17-herdr.sh'
}

test_invalid_module() {
  if OS_RELEASE_FILE="${TMP_DIR}/mint-os-release" "${REPO_ROOT}/bootstrap.sh" \
    --dry-run --with unknown >"${TMP_DIR}/invalid.out" 2>&1; then
    fail 'unknown module unexpectedly succeeded'
  fi
  grep -Fq 'unknown module: unknown' "${TMP_DIR}/invalid.out" \
    || fail 'unknown module error was not reported'
}

main() {
  write_os_fixtures
  test_mint_defaults
  test_ubuntu_defaults
  test_mint_23_base
  test_module_overrides
  test_invalid_module
  printf '[test-bootstrap] all tests passed\n'
}

main "$@"
