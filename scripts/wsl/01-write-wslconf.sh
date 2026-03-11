#!/usr/bin/env bash
# =============================================================================
# 01-write-wslconf.sh
# =============================================================================
# Purpose:
#   Write a conservative /etc/wsl.conf suitable for a developer-focused Ubuntu
#   template, with systemd enabled.
#
# Official references:
#   - WSL systemd: https://learn.microsoft.com/en-us/windows/wsl/systemd
#   - WSL advanced config: https://learn.microsoft.com/en-us/windows/wsl/wsl-config
#
# What this file does:
#   - enables systemd
#   - keeps path appending behavior explicit
#   - leaves automount mostly default/safe
#
# Important:
#   This script only writes /etc/wsl.conf inside the distro.
#   It does NOT write %UserProfile%\\.wslconfig for you.
# =============================================================================
set -Eeuo pipefail

main() {
  sudo tee /etc/wsl.conf >/dev/null <<'EOF2'
[boot]
systemd=true

[interop]
appendWindowsPath=false

[automount]
enabled=true
options="metadata,umask=22,fmask=11"
mountFsTab=false

[network]
generateHosts=true
generateResolvConf=true
EOF2

  cat <<'MSG'
[01-write-wslconf] wrote /etc/wsl.conf
[01-write-wslconf] example %UserProfile%\.wslconfig to create on Windows:

[wsl2]
memory=16GB
processors=8
swap=8GB
localhostForwarding=true

[01-write-wslconf] now run from Windows PowerShell or CMD:
  wsl --shutdown
MSG
}

main "$@"
