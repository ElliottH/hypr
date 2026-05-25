#!/usr/bin/env swift
import AppKit

let _ = NSApplication.shared

func renderIcon(size: Int) -> Data? {
    guard let rep = NSBitmapImageRep(
        bitmapDataPlanes: nil,
        pixelsWide: size, pixelsHigh: size,
        bitsPerSample: 8, samplesPerPixel: 4,
        hasAlpha: true, isPlanar: false,
        colorSpaceName: .calibratedRGB,
        bytesPerRow: 0, bitsPerPixel: 0
    ) else { return nil }
    rep.size = NSSize(width: size, height: size)

    NSGraphicsContext.saveGraphicsState()
    NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: rep)
    defer { NSGraphicsContext.restoreGraphicsState() }

    let s = CGFloat(size)
    let inset = s * 0.13
    let cornerR = s * 0.11
    let keyW = s - 2 * inset
    let depth = s * 0.030

    // Background
    NSColor(calibratedRed: 0.11, green: 0.11, blue: 0.12, alpha: 1).setFill()
    NSBezierPath.fill(NSRect(x: 0, y: 0, width: s, height: s))

    // Key shadow
    NSColor(calibratedRed: 0.07, green: 0.07, blue: 0.08, alpha: 1).setFill()
    NSBezierPath(
        roundedRect: NSRect(x: inset, y: inset - depth, width: keyW, height: keyW),
        xRadius: cornerR, yRadius: cornerR
    ).fill()

    // Key body
    NSColor(calibratedRed: 0.20, green: 0.20, blue: 0.22, alpha: 1).setFill()
    NSBezierPath(
        roundedRect: NSRect(x: inset, y: inset, width: keyW, height: keyW - depth),
        xRadius: cornerR, yRadius: cornerR
    ).fill()

    // Key face
    let fi = s * 0.020
    NSColor(calibratedRed: 0.34, green: 0.34, blue: 0.36, alpha: 1).setFill()
    NSBezierPath(
        roundedRect: NSRect(x: inset + fi, y: inset + fi,
                            width: keyW - 2 * fi, height: keyW - depth - fi),
        xRadius: cornerR - fi, yRadius: cornerR - fi
    ).fill()

    // Escape SF Symbol in white
    if let symbol = NSImage(systemSymbolName: "escape", accessibilityDescription: nil) {
        let config = NSImage.SymbolConfiguration(paletteColors: [.white])
        let colored = symbol.withSymbolConfiguration(config) ?? symbol
        let symW = keyW * 0.56
        let ratio = colored.size.height / max(colored.size.width, 1)
        let symH = symW * ratio
        colored.draw(
            in: NSRect(x: (s - symW) / 2, y: (s - symH) / 2 + depth * 0.3,
                       width: symW, height: symH),
            from: .zero, operation: .sourceOver, fraction: 1.0
        )
    }

    return rep.representation(using: .png, properties: [:])
}

// (pixel size, filename)
let sizes: [(Int, String)] = [
    (16,   "icon_16x16.png"),
    (32,   "icon_16x16@2x.png"),
    (32,   "icon_32x32.png"),
    (64,   "icon_32x32@2x.png"),
    (128,  "icon_128x128.png"),
    (256,  "icon_128x128@2x.png"),
    (256,  "icon_256x256.png"),
    (512,  "icon_256x256@2x.png"),
    (512,  "icon_512x512.png"),
    (1024, "icon_512x512@2x.png"),
]

let outDir = CommandLine.arguments.count > 1
    ? CommandLine.arguments[1]
    : "hypr/Assets.xcassets/AppIcon.appiconset"

var ok = true
for (size, name) in sizes {
    if let data = renderIcon(size: size) {
        let url = URL(fileURLWithPath: "\(outDir)/\(name)")
        do {
            try data.write(to: url)
            print("✓ \(name) (\(size)px)")
        } catch {
            print("✗ \(name): \(error.localizedDescription)")
            ok = false
        }
    } else {
        print("✗ \(name): render failed")
        ok = false
    }
}
exit(ok ? 0 : 1)
