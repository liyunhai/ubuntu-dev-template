# Troubleshooting

## Confirm the detected OS and profile

Preview detection without changing the system:

```bash
./bootstrap.sh --dry-run
```

Linux Mint should report its Mint release and its underlying Ubuntu codename,
for example Mint 22.x with `noble`. Override only the install profile, not the
detected repository codename:

```bash
./bootstrap.sh --profile server --dry-run
```

## WSL: systemd not active
Check:

```bash
ps -p 1 -o comm=
```

Expected: `systemd`

If not:
1. verify `/etc/wsl.conf` contains `systemd=true`
2. run `wsl --shutdown` from Windows
3. reopen the distro

## Docker permission denied
Make sure your user is in the docker group:

```bash
groups
```

If not, add it and re-login:

```bash
sudo usermod -aG docker "$USER"
```

Then open a new login session. Running `newgrp docker` can update the current
terminal temporarily, but a fresh login is the recommended final check.

## Docker reports conflicting packages

The Docker installer does not silently remove an existing distro-provided
Docker, Compose, Podman compatibility package, containerd, or runc. Review the
listed packages first. If Docker CE should replace them, rerun with:

```bash
./bootstrap.sh --with docker --replace-docker-packages
```

## Docker installer says systemd is not active

Regular Ubuntu Server and VMware Fusion guests should boot with systemd. Check:

```bash
ps -p 1 -o comm=
```

On WSL, run `scripts/wsl/01-write-wslconf.sh`, execute `wsl --shutdown` from
Windows, reopen Ubuntu, and rerun the installer.

## nvm not found after install
Reload shell or source your shell config:

```bash
source ~/.zshrc
```

If `~/.zshrc` was created by Oh My Zsh before this template was installed, back
it up and explicitly install the project configuration:

```bash
./scripts/common/10-shell.sh --install-zshrc-template
exec zsh -l
```

## uv installed but not on PATH
Ensure `~/.local/bin` is on PATH.

## Yazi icons are missing or terminal text is widely spaced

Install or repair the desktop font:

```bash
./scripts/common/12-nerd-font.sh --force
./checks/verify-nerd-font.sh
```

In the terminal profile, select `JetBrainsMono Nerd Font`. Do not select
`JetBrainsMono Nerd Font Mono` if GNOME Terminal renders excessive character
spacing, and do not select the proportional `Propo` variant. Fully close and
reopen the terminal after changing the font.

## OpenVPN helper credentials need to be changed

Replace the keyring entries interactively:

```bash
vpn setup
```

Remove the saved profile and credentials completely with `vpn forget`. If the
keyring is locked after login, unlock the Login keyring in the desktop password
prompt and retry `vpn-up`.
