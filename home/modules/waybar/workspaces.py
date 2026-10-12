"""Feeds the workspace modules of the bar, see config.nix.

For every numbered workspace holding a window, writes its label and the icon
of its most recently focused window to $WAYBAR_WORKSPACES, then signals the
bar given as argument so that it reads them again. Runs for as long as
Hyprland sends events.
"""
import html
import json
import os
import signal
import socket
import sys
import time
from pathlib import Path

from xdg import BaseDirectory, IconTheme

WORKSPACES = range(1, 11)
# `signal` of the modules in config.nix
SIGNAL = signal.SIGRTMIN + 8
# Anything that can change which workspaces are used, the last focused
# window of one of them or the active one.
EVENTS = {
    "workspacev2",
    "focusedmonv2",
    "activewindowv2",
    "openwindow",
    "closewindow",
    "movewindowv2",
    "activespecialv2",
}

HYPR = (
    Path(os.environ["XDG_RUNTIME_DIR"])
    / "hypr"
    / os.environ["HYPRLAND_INSTANCE_SIGNATURE"]
)
OUT = Path(os.environ["WAYBAR_WORKSPACES"])

icons = {}
missing = {}


def request(command):
    with socket.socket(socket.AF_UNIX) as sock:
        sock.connect(str(HYPR / ".socket.sock"))
        sock.sendall(command.encode())
        chunks = []
        while chunk := sock.recv(65536):
            chunks.append(chunk)
    return json.loads(b"".join(chunks))


def desktop_icons():
    """Icon name of every desktop entry, by the names a window class may
    take: its id, its StartupWMClass and the last part of a reverse DNS id."""
    exact, loose = {}, {}
    for directory in BaseDirectory.load_data_paths("applications"):
        for path in sorted(Path(directory).glob("*.desktop")):
            entry = {}
            section = None
            try:
                lines = path.read_text(errors="replace").splitlines()
            except OSError:
                continue
            for line in lines:
                if line.startswith("["):
                    section = line.strip()
                elif section == "[Desktop Entry]" and "=" in line:
                    key, _, value = line.partition("=")
                    entry.setdefault(key.strip(), value.strip())
            icon = entry.get("Icon")
            if not icon:
                continue
            exact.setdefault(path.stem.lower(), icon)
            if "StartupWMClass" in entry:
                exact.setdefault(entry["StartupWMClass"].lower(), icon)
            loose.setdefault(path.stem.rsplit(".", 1)[-1].lower(), icon)
    return {**loose, **exact}


def icon_path(name):
    if os.path.isabs(name):
        return name if os.path.exists(name) else None
    return IconTheme.getIconPath(name, 48)


def icon_for(client):
    """Path of the icon of a window, empty when it has none."""
    names = [client.get("class"), client.get("initialClass")]
    names = tuple(name for name in names if name)
    if names in icons:
        return icons[names]
    # Desktop entries may have been installed since, but do not scan them
    # again on every event.
    if time.monotonic() - missing.get(names, -60) < 30:
        return ""
    entries = desktop_icons()
    for name in names:
        for candidate in (entries.get(name.lower()), name, name.lower()):
            path = candidate and icon_path(candidate)
            if path:
                icons[names] = path
                return path
    missing[names] = time.monotonic()
    return ""


def snapshot():
    """Content of every file of OUT."""
    active = request("j/activeworkspace").get("id")
    last = {}
    for client in request("j/clients"):
        workspace = client["workspace"]["id"]
        if not client["mapped"]:
            continue
        if (
            workspace not in last
            or client["focusHistoryID"] < last[workspace]["focusHistoryID"]
        ):
            last[workspace] = client

    files = {}
    for workspace in WORKSPACES:
        client = last.get(workspace)
        label = {"text": ""}
        icon = ""
        if client is not None:
            title = html.escape(" ".join(client["title"].split()))
            label = {
                "text": str(workspace),
                "class": "active" if workspace == active else "inactive",
                "tooltip": title,
            }
            icon = f"{icon_for(client)}\n{title}"
        files[f"{workspace}.json"] = json.dumps(label)
        files[f"{workspace}.icon"] = icon
    return files


def publish(files, previous):
    for name, content in files.items():
        if previous.get(name) != content:
            temporary = OUT / f".{name}"
            temporary.write_text(content + "\n")
            temporary.replace(OUT / name)
    return files != previous


def listening(pid):
    """Whether the bar handles SIGNAL yet, which kills it until then."""
    masks = 0
    for line in Path(f"/proc/{pid}/status").read_text().splitlines():
        key, _, value = line.partition(":")
        if key in ("SigBlk", "SigCgt"):
            masks |= int(value, 16)
    return bool(masks >> (SIGNAL - 1) & 1)


def main():
    bar = int(sys.argv[1])
    OUT.mkdir(parents=True, exist_ok=True)

    events = socket.socket(socket.AF_UNIX)
    events.connect(str(HYPR / ".socket2.sock"))

    try:
        while not listening(bar):
            time.sleep(0.05)

        files = {}
        buffer = b""
        while True:
            current = snapshot()
            if publish(current, files):
                os.kill(bar, SIGNAL)
            files = current

            relevant = False
            while not relevant:
                data = events.recv(4096)
                if not data:
                    return
                *lines, buffer = (buffer + data).split(b"\n")
                relevant = any(
                    line.split(b">>")[0].decode() in EVENTS for line in lines
                )
    except (ProcessLookupError, FileNotFoundError):
        # The bar is gone
        return


if __name__ == "__main__":
    main()
