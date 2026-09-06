#!/usr/bin/env bash

backup_config_file() {
  local target="$1"
  local backup
  backup="${target}.bak.$(date +%Y%m%d-%H%M%S)"
  cp -a -- "$target" "$backup"
  printf '[config] backed up %s -> %s\n' "$target" "$backup"
}

install_config_file() {
  local source="$1"
  local target="$2"
  local mode="${3:-0644}"

  [[ -f "$source" ]] || {
    printf '[config] ERROR: source file not found: %s\n' "$source" >&2
    return 1
  }

  mkdir -p "$(dirname "$target")"
  if [[ -f "$target" ]]; then
    if cmp -s -- "$source" "$target"; then
      printf '[config] unchanged: %s\n' "$target"
      return 0
    fi
    backup_config_file "$target"
  fi

  install -m "$mode" "$source" "$target"
  printf '[config] installed: %s\n' "$target"
}
