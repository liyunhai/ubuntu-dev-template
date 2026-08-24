# Ubuntu Dev Template

A cross-platform Ubuntu 24.04 development template for:

- Windows 11 + WSL 2
- macOS + OrbStack Ubuntu machines

This repository provides:

- install scripts
- dotfiles
- sample nginx/docker/project templates
- verification scripts

## Design goals

1. Keep the **Ubuntu userland** as similar as possible across WSL and OrbStack.
2. Keep **host-specific integration** outside Ubuntu where possible.
3. Prefer **simple, official installation paths** over clever but brittle ones.
4. Make scripts **idempotent** and easy to read/modify.

## High-level choices

- Shell: zsh + Oh My Zsh + Powerlevel10k
- Terminal workspaces: tmux + Zellij + Herdr
- Terminal file manager: Yazi (latest stable release)
- Python: system python + venv + pipx + uv
- Node.js: nvm + latest LTS + pnpm
- Database: PostgreSQL native, other DBs primarily via containers
- Web server: nginx native
- Containers:
  - WSL: native Docker Engine inside Ubuntu
  - OrbStack: prefer OrbStack's built-in container engine
- Workspace root: `~/workspace`

## Installation order

`00-base.sh` and `10-shell.sh` are the required foundation. Run both first:

```bash
./scripts/common/00-base.sh
./scripts/common/10-shell.sh
```

Then run the modules you want. Every module remains a separate install script:

```text
scripts/common/15-tmux.sh
scripts/common/16-zellij.sh
scripts/common/17-herdr.sh
scripts/common/18-yazi.sh
scripts/common/20-direnv.sh
scripts/common/30-python.sh
scripts/common/40-node.sh
scripts/common/50-db-clients.sh
scripts/common/60-postgres.sh
scripts/common/70-nginx.sh
scripts/wsl/00-wsl-preflight.sh           # WSL only
scripts/wsl/01-write-wslconf.sh           # WSL only
scripts/wsl/02-docker-engine.sh           # WSL only
scripts/common/80-devtools.sh
scripts/common/90-verify.sh
```

The terminal tools can coexist. They are not configured to start or nest one
another automatically:

- tmux: established terminal multiplexer with TPM plugins
- Zellij: modern general-purpose terminal workspace
- Herdr: terminal workspace focused on coding-agent workflows
- Yazi: terminal file manager

Zellij, Herdr, and Yazi install their latest stable release to `~/.local/bin`.
Release checksums are verified before installation. Existing user configuration
is backed up before the template configuration is installed.

The proxy helper is not an installer. Evaluate its output in the current shell:

```bash
eval "$(python3 scripts/common/99-proxy-switch.py home)"
eval "$(python3 scripts/common/99-proxy-switch.py off)"
```

## Important notes

- **Fonts are installed on the host OS**, not inside WSL/Ubuntu.
- On WSL, keep active projects under the Linux filesystem, e.g. `~/workspace`, not primarily under `/mnt/c/...`.
- On OrbStack, keep Ubuntu-side paths and shell workflows aligned with WSL.

## Reference docs

These scripts follow the official docs as closely as practical:

- WSL systemd and config: https://learn.microsoft.com/en-us/windows/wsl/systemd
- WSL advanced config: https://learn.microsoft.com/en-us/windows/wsl/wsl-config
- Docker Engine on Ubuntu: https://docs.docker.com/engine/install/ubuntu/
- Docker post-install steps: https://docs.docker.com/engine/install/linux-postinstall/
- OrbStack machines: https://docs.orbstack.dev/machines/
- OrbStack machine CLI: https://docs.orbstack.dev/machines/commands
- Ubuntu nginx install/config: https://ubuntu.com/server/docs/how-to/web-services/install-nginx/
- uv installation: https://docs.astral.sh/uv/getting-started/installation/
- pre-commit: https://pre-commit.com/
- PostgreSQL on Ubuntu: https://www.postgresql.org/download/linux/ubuntu/
- Node.js download page (nvm guidance): https://nodejs.org/en/download
- Zellij installation: https://zellij.dev/documentation/installation.html
- Herdr installation: https://herdr.dev/docs/install/
- Yazi installation: https://yazi-rs.github.io/docs/installation
