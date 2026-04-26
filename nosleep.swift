#!/usr/bin/env swift

import Cocoa

class NoSleep: NSObject, NSApplicationDelegate {
    var statusItem: NSStatusItem!
    var caffeinate: Process?

    func applicationDidFinishLaunching(_ notification: Notification) {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        if let button = statusItem.button {
            button.action = #selector(handleClick(_:))
            button.target = self
            button.sendAction(on: [.leftMouseUp, .rightMouseUp])
        }
        render()
    }

    @objc func handleClick(_ sender: Any?) {
        if NSApp.currentEvent?.type == .rightMouseUp {
            let menu = NSMenu()
            menu.addItem(NSMenuItem(title: "Quit nosleep", action: #selector(quit), keyEquivalent: "q"))
            statusItem.menu = menu
            statusItem.button?.performClick(nil)
            statusItem.menu = nil
        } else {
            toggle()
        }
    }

    func toggle() {
        if caffeinate != nil { stop() } else { start() }
        render()
    }

    func start() {
        let p = Process()
        p.launchPath = "/usr/bin/caffeinate"
        p.arguments = ["-d"]
        p.terminationHandler = { [weak self] _ in
            DispatchQueue.main.async {
                self?.caffeinate = nil
                self?.render()
            }
        }
        do {
            try p.run()
            caffeinate = p
        } catch {
            NSLog("nosleep: failed to start caffeinate: \(error)")
        }
    }

    func stop() {
        caffeinate?.terminate()
        caffeinate?.waitUntilExit()
        caffeinate = nil
    }

    func render() {
        guard let button = statusItem.button else { return }
        let active = caffeinate != nil
        let symbol = active ? "cup.and.saucer.fill" : "moon.zzz.fill"
        let cfg = NSImage.SymbolConfiguration(pointSize: 14, weight: .regular)
        if let img = NSImage(systemSymbolName: symbol, accessibilityDescription: "nosleep")?
            .withSymbolConfiguration(cfg) {
            img.isTemplate = true
            button.image = img
            button.title = ""
        } else {
            button.image = nil
            button.title = active ? "☕︎" : "z"
        }
        button.toolTip = active ? "nosleep: ON (click to disable)" : "nosleep: OFF (click to enable)"
    }

    @objc func quit() {
        stop()
        NSApp.terminate(nil)
    }
}

let app = NSApplication.shared
app.setActivationPolicy(.accessory)
let delegate = NoSleep()
app.delegate = delegate
app.run()
