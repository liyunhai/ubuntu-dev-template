# Troubleshooting

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

## uv installed but not on PATH
Ensure `~/.local/bin` is on PATH.
