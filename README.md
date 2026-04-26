# nosleep

A tiny macOS menu bar app that toggles `caffeinate -d` on or off with a click. Replaces the habit of running `caffeinate -d` in a tmux tab.

## What it does

- ☕️ **On** — `caffeinate -d` is running; the display will not sleep.
- 🌙 **Off** — normal sleep behavior.

Left-click the menu bar icon to toggle. Right-click for a Quit menu.

## Requirements

- macOS 11+
- Xcode command line tools (`xcode-select --install`) — provides `swiftc` and `iconutil`.

## Build

```sh
./build.sh
```

Produces `nosleep.app` in the project directory. Drag it to `/Applications` (or `~/Applications`) to install:

```sh
cp -R nosleep.app /Applications/
```

`nosleep` is now searchable in Spotlight.

## Auto-start at login

The shipped `dev.nymann.nosleep.plist` expects the app at `/Applications/nosleep.app`. Adjust the path inside if you installed it elsewhere, then:

```sh
cp dev.nymann.nosleep.plist ~/Library/LaunchAgents/
launchctl bootstrap gui/$(id -u) ~/Library/LaunchAgents/dev.nymann.nosleep.plist
launchctl kickstart gui/$(id -u)/dev.nymann.nosleep
```

Uninstall:

```sh
launchctl bootout gui/$(id -u)/dev.nymann.nosleep
rm ~/Library/LaunchAgents/dev.nymann.nosleep.plist
```

## Notes

- `KeepAlive` is set to `SuccessfulExit: false`, so quitting via the menu won't auto-respawn — only crashes do.
- The app is ad-hoc codesigned during build (`codesign --sign -`), enough for local use without entitlements.
- `LSUIElement` is set, so there's no Dock icon — only the menu bar item.
- Run `swift nosleep.swift` directly during development to skip the bundle build.
