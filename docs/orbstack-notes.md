# OrbStack notes

## Strategy
Keep the Ubuntu machine userland aligned with WSL:
- same username if possible
- same `~/workspace` layout
- same shell config
- same python/node workflow

## Docker difference
OrbStack already runs a Docker engine alongside Linux machines. In most cases, you should use OrbStack's built-in engine instead of installing another Docker Engine inside the Ubuntu machine.

## Networking
OrbStack machines expose convenient domain names such as `machine-name.orb.local`.
