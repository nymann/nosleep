# nosleep

A tiny macOS menu bar app that toggles `caffeinate -d` on or off with a click. Replaces the habit of running `caffeinate -d` in a tmux tab.

## What it does

- ☕️ **On** — `caffeinate -d` is running; the display will not sleep.
- 🌙 **Off** — normal sleep behavior.

Left-click the menu bar icon to toggle. Right-click for a Quit menu.

## Requirements

- macOS 11+
- Xcode command line tools (`xcode-select --install`) — provides `swiftc` and `iconutil`.
- [`just`](https://github.com/casey/just) — `brew install just`.

## Quick start

```sh
just install        # build nosleep.app and copy it to /Applications
just agent-install  # auto-start at login via launchd
```

`nosleep` is now searchable in Spotlight, and the menu bar icon will reappear at every login.

## All recipes

```
just build            Build nosleep.app in the project directory
just install          Build, then copy nosleep.app to /Applications
just uninstall        Remove nosleep.app from /Applications
just run              Run the script directly (skips bundle build)
just agent-install    Install the LaunchAgent so nosleep starts at login
just agent-restart    Restart the LaunchAgent (use after rebuilding)
just agent-uninstall  Uninstall the LaunchAgent
just clean            Remove build artifacts
```

After editing the source, the typical loop is:

```sh
just install agent-restart
```

## Notes

- `KeepAlive` is set to `SuccessfulExit: false`, so quitting via the menu won't auto-respawn — only crashes do.
- The bundle is ad-hoc codesigned (`codesign --sign -`), enough for local use without entitlements.
- `LSUIElement` is set, so there's no Dock icon — only the menu bar item.
