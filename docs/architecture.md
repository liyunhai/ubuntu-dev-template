# Architecture

## Layered model

### L0 Host / virtualization
- WSL 2 on Windows 11, OrbStack on macOS, a regular Ubuntu VM, or Linux Mint
- Ubuntu Server or Linux Mint desktop base machine
- systemd enabled where appropriate

### L1 Base packages
Common tools used by everything else:
- build-essential, git, curl, gnupg, unzip, jq, tmux, ripgrep, fd, etc.

### L2 Shell / terminal UX
- zsh
- Oh My Zsh
- Powerlevel10k
- JetBrainsMono Nerd Font on native Linux desktops
- zsh plugins
- tmux
- Zellij
- Herdr
- Yazi
- host-side Nerd Font configuration

### L3 Environment management
- direnv for per-project env activation
- uv for Python workflows
- nvm + pnpm for Node.js workflows

### L4 Language runtimes
- Python: system python + venv + pipx + uv
- Node.js: nvm + current LTS node

### L5 Data + web services
- PostgreSQL native
- nginx native
- Other data services containerized when useful

### L6 Containers
- Ubuntu VM / WSL: native Docker Engine inside Ubuntu
- OrbStack: prefer built-in engine provided by OrbStack

### L7 Dev quality / tooling
- pre-commit
- shellcheck
- yamllint
- shfmt
- GitHub CLI

### L8 Template assets
- dotfiles
- service configs
- compose examples
- verification scripts

## Profiles and platform detection

`bootstrap.sh` separates the OS, runtime platform, and install profile:

- OS controls compatibility and the Ubuntu repository codename. Both Ubuntu
  and Linux Mint are supported.
- Platform controls WSL and OrbStack integration; other systems are `native`.
- Profile controls module selection. `server` includes services and Docker;
  `desktop` adds the local Nerd Font while keeping Docker, PostgreSQL, and nginx
  opt-in.

Profiles only select shared modules. Distribution-specific scripts should be
added only when behavior genuinely cannot be expressed by the helpers under
`scripts/lib`.
