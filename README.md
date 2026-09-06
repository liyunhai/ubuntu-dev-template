# Ubuntu Dev Template

A cross-platform Ubuntu-family development template for:

- Windows 11 + WSL 2
- macOS + OrbStack Ubuntu machines
- macOS + VMware Fusion Ubuntu virtual machines
- regular Ubuntu Server installations
- Linux Mint desktop installations

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
- Desktop font: JetBrainsMono Nerd Font (native Linux desktop profile)
- Terminal workspaces: tmux + Zellij + Herdr
- Terminal file manager: Yazi (latest stable release)
- Python: system python + venv + pipx + uv
- Node.js: nvm + latest LTS + pnpm
- Database: PostgreSQL native, other DBs primarily via containers
- Web server: nginx native
- Containers:
  - Ubuntu VM / WSL: native Docker Engine inside Ubuntu
  - OrbStack: prefer OrbStack's built-in container engine
- Workspace root: `~/workspace`

## Installation profiles

The bootstrapper reads `/etc/os-release` and chooses a default profile:

- Ubuntu: `server`
- Linux Mint: `desktop`

The server profile installs the server-oriented modules. The desktop profile
also installs JetBrainsMono Nerd Font, but leaves Docker, PostgreSQL, and nginx
opt-in. Neither profile changes the login shell unless `--set-default-shell` is
provided.

Run the detected default from the repository root:

```bash
./bootstrap.sh
```

Choose a profile or customize its modules:

```bash
./bootstrap.sh --profile desktop
./bootstrap.sh --profile desktop --with docker,postgres
./bootstrap.sh --profile server --skip nginx
./bootstrap.sh --profile desktop --set-default-shell
```

Available modules are `base`, `shell`, `nerd-font`, `tmux`, `zellij`, `herdr`,
`yazi`, `direnv`, `python`, `node`, `db-clients`, `postgres`, `nginx`, `docker`,
and `devtools`.

Before replacing an existing distro-provided Docker installation, inspect the
reported conflicting packages and explicitly approve their removal:

```bash
./bootstrap.sh --with docker --replace-docker-packages
```

The script also detects native Linux, WSL, or OrbStack automatically. Preview
the execution plan without changing the system:

```bash
./bootstrap.sh --dry-run
```

On WSL without systemd, the first run writes `/etc/wsl.conf` and stops. Run
`wsl --shutdown` from Windows, reopen Ubuntu, and run `./bootstrap.sh` again.

## Individual installation

`00-base.sh` is the required foundation. Install the shell layer if wanted:

```bash
./scripts/common/00-base.sh
./scripts/common/10-shell.sh
./scripts/common/12-nerd-font.sh             # native Linux desktop
```

Then run the modules you want. Every module remains a separate install script:

```text
scripts/common/15-tmux.sh
scripts/common/16-zellij.sh
scripts/common/17-herdr.sh
scripts/common/18-yazi.sh
scripts/common/19-openvpn-helper.sh          # optional OpenVPN 3 shortcuts
scripts/common/20-direnv.sh
scripts/common/30-python.sh
scripts/common/40-node.sh
scripts/common/50-db-clients.sh
scripts/common/60-postgres.sh
scripts/common/70-nginx.sh
scripts/common/75-docker-engine.sh            # Ubuntu VM / WSL
scripts/wsl/00-wsl-preflight.sh           # WSL only
scripts/wsl/01-write-wslconf.sh           # WSL only
scripts/wsl/02-docker-engine.sh           # WSL compatibility entry point
scripts/common/80-devtools.sh
scripts/common/90-verify.sh
```

For VMware Fusion or another regular Ubuntu VM, install Docker directly with:

```bash
./scripts/common/75-docker-engine.sh
```

Open a new login session after Docker installation so membership in the
`docker` group takes effect. Docker's Ubuntu repository is configured with the
underlying Ubuntu codename (`UBUNTU_CODENAME` on Linux Mint).

The terminal tools can coexist. They are not configured to start or nest one
another automatically:

- tmux: established terminal multiplexer with TPM plugins
- Zellij: modern general-purpose terminal workspace
- Herdr: terminal workspace focused on coding-agent workflows
- Yazi: terminal file manager

Zellij, Herdr, and Yazi install their latest stable release to `~/.local/bin`.
Release checksums are verified before installation. Existing user configuration
is backed up before the template configuration is installed.

The shell template adds `~/.local/bin` and `~/bin` to interactive zsh sessions
and loads nvm from `~/.nvm`. On an existing installation, explicitly back up and
replace `~/.zshrc` with the project template by running:

```bash
./scripts/common/10-shell.sh --install-zshrc-template
```

The Nerd Font module installs the four standard `JetBrainsMono Nerd Font`
styles for the current user. In GNOME Terminal, select `JetBrainsMono Nerd
Font` rather than its `Mono` or `Propo` variants, then fully reopen the terminal.

For an existing OpenVPN 3 Linux installation, the optional helper provides
`vpn-up`, `vpn-down`, `vpn-status`, and `vpn-restart`. Run `vpn setup` once;
credentials are stored in the desktop system keyring and are never written to
the repository or a plaintext credentials file.

The proxy helper is not an installer. Evaluate its output in the current shell:

```bash
eval "$(python3 scripts/common/99-proxy-switch.py home)"
eval "$(python3 scripts/common/99-proxy-switch.py off)"
```

## Important notes

- **Fonts are installed on the terminal host OS**, not inside WSL or an
  OrbStack guest. Do not opt into `nerd-font` inside those guests.
- On Linux Mint desktop, the desktop itself is the host and the desktop profile
  installs JetBrainsMono Nerd Font into `~/.local/share/fonts`.
- On WSL, keep active projects under the Linux filesystem, e.g. `~/workspace`, not primarily under `/mnt/c/...`.
- On OrbStack, keep Ubuntu-side paths and shell workflows aligned with WSL.
- Docker Engine officially supports Ubuntu 26.04 Resolute; the installer derives
  the repository suite and architecture from the running Ubuntu system.

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

## Development checks

Run the profile and OS-detection smoke tests without installing packages:

```bash
./tests/test-bootstrap.sh
```
