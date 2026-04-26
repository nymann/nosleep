app := "nosleep.app"
agent := "dev.nymann.nosleep"
plist := agent + ".plist"

default: build

# Build nosleep.app in the project directory
build:
    #!/usr/bin/env bash
    set -euo pipefail
    rm -rf {{app}}
    mkdir -p {{app}}/Contents/MacOS {{app}}/Contents/Resources
    swiftc -O nosleep.swift -o {{app}}/Contents/MacOS/nosleep
    iconset="$(mktemp -d)/AppIcon.iconset"
    mkdir -p "$iconset"
    swift make-icon.swift "$iconset"
    iconutil -c icns "$iconset" -o {{app}}/Contents/Resources/AppIcon.icns
    cp Info.plist {{app}}/Contents/Info.plist
    codesign --force --sign - {{app}}

# Build, then copy nosleep.app to /Applications
install: build
    cp -R {{app}} /Applications/

# Remove nosleep.app from /Applications
uninstall:
    rm -rf /Applications/{{app}}

# Run the script directly (skips bundle build)
run:
    swift nosleep.swift

# Install the LaunchAgent so nosleep starts at login
agent-install:
    #!/usr/bin/env bash
    set -e
    cp {{plist}} ~/Library/LaunchAgents/
    launchctl bootout "gui/$(id -u)/{{agent}}" 2>/dev/null || true
    launchctl bootstrap "gui/$(id -u)" ~/Library/LaunchAgents/{{plist}}

# Restart the LaunchAgent (use after rebuilding)
agent-restart:
    launchctl kickstart -k "gui/$(id -u)/{{agent}}"

# Uninstall the LaunchAgent
agent-uninstall:
    -launchctl bootout "gui/$(id -u)/{{agent}}"
    rm -f ~/Library/LaunchAgents/{{plist}}

# Remove build artifacts
clean:
    rm -rf {{app}}
