import AppKit

class AboutWindowController: NSWindowController {
    convenience init() {
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 280, height: 200),
            styleMask: [.titled, .closable],
            backing: .buffered,
            defer: false
        )
        window.title = "About hypr"
        window.isReleasedWhenClosed = false
        self.init(window: window)

        let icon = NSImageView()
        icon.image = NSImage(named: NSImage.applicationIconName)
        icon.translatesAutoresizingMaskIntoConstraints = false

        let name = NSTextField(labelWithString: "hypr")
        name.font = .boldSystemFont(ofSize: 15)

        let summary = NSTextField(labelWithString: "Tiny Hyper key daemon for macOS")
        summary.font = .systemFont(ofSize: 11)
        summary.textColor = .secondaryLabelColor

        let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? ""
        let build   = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? ""
        let versionLabel = NSTextField(labelWithString: "Version \(version) (\(build))")
        versionLabel.font = .systemFont(ofSize: 11)
        versionLabel.textColor = .secondaryLabelColor

        let link = NSButton(title: "", target: self, action: #selector(openGitHub))
        link.isBordered = false
        link.attributedTitle = NSAttributedString(
            string: "github.com/ElliottH/hypr",
            attributes: [
                .foregroundColor: NSColor.linkColor,
                .underlineStyle: NSUnderlineStyle.single.rawValue,
                .font: NSFont.systemFont(ofSize: 11),
            ]
        )

        let stack = NSStackView(views: [icon, name, summary, versionLabel, link])
        stack.orientation = .vertical
        stack.alignment = .centerX
        stack.spacing = 4
        stack.setCustomSpacing(10, after: icon)
        stack.setCustomSpacing(10, after: versionLabel)
        stack.translatesAutoresizingMaskIntoConstraints = false

        let content = NSView()
        content.addSubview(stack)
        window.contentView = content

        NSLayoutConstraint.activate([
            icon.widthAnchor.constraint(equalToConstant: 64),
            icon.heightAnchor.constraint(equalToConstant: 64),
            stack.centerXAnchor.constraint(equalTo: content.centerXAnchor),
            stack.centerYAnchor.constraint(equalTo: content.centerYAnchor),
        ])
    }

    @objc private func openGitHub() {
        NSWorkspace.shared.open(URL(string: "https://github.com/ElliottH/hypr")!)
    }

    func show() {
        window?.center()
        window?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
}
