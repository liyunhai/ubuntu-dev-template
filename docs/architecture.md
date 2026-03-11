# Architecture

## Layered model

### L0 Host / virtualization
- WSL 2 on Windows 11, or OrbStack machine on macOS
- Ubuntu 24.04 base machine
- systemd enabled where appropriate

### L1 Base packages
Common tools used by everything else:
- build-essential, git, curl, gnupg, unzip, jq, tmux, ripgrep, fd, etc.

### L2 Shell / terminal UX
- zsh
- Oh My Zsh
- Powerlevel10k
- zsh plugins
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
- WSL: native Docker Engine inside Ubuntu
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
