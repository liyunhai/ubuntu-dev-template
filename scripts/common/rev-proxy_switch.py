#!/usr/bin/env python3
"""Switch HTTP/HTTPS proxy settings for the current shell.

Usage (bash/zsh):
    eval "$(python3 proxy_switch.py home)"
    eval "$(python3 proxy_switch.py com_inner)"
    eval "$(python3 proxy_switch.py com_outer)"
    eval "$(python3 proxy_switch.py off)"
"""

import argparse
import shlex
import sys


# Destinations that should bypass the proxy. Individual proxy groups can
# override this value by defining their own "no_proxy" entry below.
DEFAULT_NO_PROXY = ",".join(
    (
        "localhost",
        "127.0.0.1",
        "::1",
        ".local",
        ".lan",
        "10.0.0.0/8",
        "172.16.0.0/12",
        "192.168.0.0/16",
        "fc00::/7",
        "fe80::/10",
    )
)


# Modify these proxy addresses to match your environment.
PROXY_GROUPS = {
    "home": {
        "http_proxy": "http://192.168.1.82:20171",
        "https_proxy": "http://192.168.1.82:20171",
    },
    "com_inner": {
        "http_proxy": "http://192.168.1.82:20171",
        "https_proxy": "http://192.168.1.82:20171",
    },
    "com_outer": {
        "http_proxy": "http://36.7.136.48:20171",
        "https_proxy": "http://36.7.136.48:20171",
    },
}


def export_commands(group_name: str) -> str:
    """Return shell commands that set one proxy group."""
    proxy = PROXY_GROUPS[group_name]
    http_proxy = shlex.quote(proxy["http_proxy"])
    https_proxy = shlex.quote(proxy["https_proxy"])
    no_proxy = shlex.quote(proxy.get("no_proxy", DEFAULT_NO_PROXY))

    # Set lowercase and uppercase names for compatibility with more programs.
    return "\n".join(
        (
            f"export http_proxy={http_proxy}",
            f"export https_proxy={https_proxy}",
            f"export HTTP_PROXY={http_proxy}",
            f"export HTTPS_PROXY={https_proxy}",
            f"export no_proxy={no_proxy}",
            f"export NO_PROXY={no_proxy}",
            f"echo 'Proxy group switched to: {group_name}' >&2",
        )
    )


def unset_commands() -> str:
    """Return shell commands that remove proxy variables."""
    return "\n".join(
        (
            "unset http_proxy https_proxy HTTP_PROXY HTTPS_PROXY no_proxy NO_PROXY",
            "echo 'Proxy disabled' >&2",
        )
    )


def main() -> int:
    parser = argparse.ArgumentParser(description="Switch proxy group for the current shell")
    parser.add_argument(
        "group",
        choices=(*PROXY_GROUPS.keys(), "off"),
        help="proxy group name, or 'off' to clear proxy variables",
    )
    args = parser.parse_args()

    if args.group == "off":
        print(unset_commands())
    else:
        print(export_commands(args.group))

    return 0


if __name__ == "__main__":
    sys.exit(main())
