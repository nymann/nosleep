# nosleep

A tiny macOS menu bar app that toggles `caffeinate -d` on or off with a click. Replaces the habit of running `caffeinate -d` in a tmux tab.

## What it does

- ☕️ **On** — `caffeinate -d` is running; the display will not sleep.
- 🌙 **Off** — normal sleep behavior.

Left-click the menu bar icon to toggle. Right-click for a Quit menu.

## Requirements

- macOS
- Xcode command line tools (`xcode-select --install`) — provides `/usr/bin/swift`.

## Run it once

```sh
swift nosleep.swift
```

## Auto-start at login

Install the LaunchAgent:

```sh
cp dev.nymann.nosleep.plist ~/Library/LaunchAgents/
launchctl bootstrap gui/$(id -u) ~/Library/LaunchAgents/dev.nymann.nosleep.plist
launchctl kickstart -k gui/$(id -u)/dev.nymann.nosleep
```

Uninstall:

```sh
launchctl bootout gui/$(id -u)/dev.nymann.nosleep
rm ~/Library/LaunchAgents/dev.nymann.nosleep.plist
```

## Notes

- The plist hardcodes the path to `nosleep.swift`. If you move the repo, edit `dev.nymann.nosleep.plist` accordingly.
- `KeepAlive` is set to `SuccessfulExit: false`, so quitting via the menu won't auto-respawn — only crashes do.
- For faster startup, compile once with `swiftc nosleep.swift -o nosleep` and point the plist's `ProgramArguments` at the binary.
