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
    rm -rf {{app}} build

# Tag, build, zip and publish a GitHub release. Triggers the
# bump-cask workflow which opens a PR against nymann/homebrew-tap.
release VERSION:
    #!/usr/bin/env bash
    set -euo pipefail
    if [[ -n "$(git status --porcelain)" ]]; then
        echo "working tree dirty — commit or stash before releasing" >&2
        exit 1
    fi
    just build
    mkdir -p build
    rm -f build/nosleep-*.zip
    ditto -c -k --sequesterRsrc --keepParent {{app}} build/nosleep-{{VERSION}}.zip
    git tag -a v{{VERSION}} -m "v{{VERSION}}"
    git push origin v{{VERSION}}
    gh release create v{{VERSION}} build/nosleep-{{VERSION}}.zip \
        --title "v{{VERSION}}" --generate-notes
