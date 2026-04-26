#!/usr/bin/env swift

import Cocoa

let outDir = CommandLine.arguments.count > 1 ? CommandLine.arguments[1] : "AppIcon.iconset"
try? FileManager.default.createDirectory(atPath: outDir, withIntermediateDirectories: true)

let sizes: [(Int, Int, String)] = [
    (16, 1, "icon_16x16.png"),
    (16, 2, "icon_16x16@2x.png"),
    (32, 1, "icon_32x32.png"),
    (32, 2, "icon_32x32@2x.png"),
    (128, 1, "icon_128x128.png"),
    (128, 2, "icon_128x128@2x.png"),
    (256, 1, "icon_256x256.png"),
    (256, 2, "icon_256x256@2x.png"),
    (512, 1, "icon_512x512.png"),
    (512, 2, "icon_512x512@2x.png"),
]

func renderIcon(pixels: Int) -> NSImage {
    let size = CGFloat(pixels)
    let img = NSImage(size: NSSize(width: size, height: size))
    img.lockFocus()

    let rect = NSRect(x: 0, y: 0, width: size, height: size)
    let radius = size * 0.225
    let bg = NSBezierPath(roundedRect: rect, xRadius: radius, yRadius: radius)

    let gradient = NSGradient(colors: [
        NSColor(calibratedRed: 0.45, green: 0.30, blue: 0.21, alpha: 1.0),
        NSColor(calibratedRed: 0.22, green: 0.13, blue: 0.08, alpha: 1.0),
    ])!
    NSGraphicsContext.saveGraphicsState()
    bg.addClip()
    gradient.draw(in: rect, angle: -90)
    NSGraphicsContext.restoreGraphicsState()

    let pointSize = size * 0.58
    let cfg = NSImage.SymbolConfiguration(pointSize: pointSize, weight: .semibold)
    if let symbol = NSImage(systemSymbolName: "cup.and.saucer.fill", accessibilityDescription: nil)?
        .withSymbolConfiguration(cfg) {
        let symbolSize = symbol.size
        let drawRect = NSRect(
            x: (size - symbolSize.width) / 2,
            y: (size - symbolSize.height) / 2 - size * 0.02,
            width: symbolSize.width,
            height: symbolSize.height
        )
        let cream = NSColor(calibratedRed: 0.98, green: 0.94, blue: 0.86, alpha: 1.0)
        let tinted = NSImage(size: symbolSize, flipped: false) { rect in
            cream.set()
            rect.fill()
            symbol.draw(in: rect, from: .zero, operation: .destinationIn, fraction: 1)
            return true
        }
        tinted.draw(in: drawRect)
    }

    img.unlockFocus()
    return img
}

for (size, scale, name) in sizes {
    let pixels = size * scale
    let img = renderIcon(pixels: pixels)
    if let tiff = img.tiffRepresentation,
       let rep = NSBitmapImageRep(data: tiff),
       let png = rep.representation(using: .png, properties: [:]) {
        let url = URL(fileURLWithPath: outDir).appendingPathComponent(name)
        try? png.write(to: url)
    }
}
