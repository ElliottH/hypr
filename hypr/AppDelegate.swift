import AppKit
import Carbon.HIToolbox
import ServiceManagement

class AppDelegate: NSObject, NSApplicationDelegate, NSMenuDelegate {
    private var statusItem: NSStatusItem?
    private var handler: Handler?
    private var statusTimer: Timer?
    private var aboutWindowController: AboutWindowController?
    private var isAccessibilityGranted = false
    private var isSecureInputActive = false

    func applicationDidFinishLaunching(_ notification: Notification) {
        isAccessibilityGranted = AXIsProcessTrusted()
        isSecureInputActive = IsSecureEventInputEnabled()
        setupMenuBar()
        registerLaunchAtLogin()
        if !isAccessibilityGranted {
            CGRequestPostEventAccess()
        } else {
            startEventTap()
        }
        startStatusPolling()
    }

    private func setupMenuBar() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        updateStatusIcon()
        rebuildMenu()
    }

    private func updateStatusIcon() {
        guard let button = statusItem?.button else { return }
        if !isAccessibilityGranted {
            button.image = NSImage(systemSymbolName: "escape", accessibilityDescription: "hypr")?
                .withSymbolConfiguration(.init(paletteColors: [.systemRed, .labelColor]))
        } else if isSecureInputActive {
            button.image = NSImage(systemSymbolName: "escape", accessibilityDescription: "hypr")?
                .withSymbolConfiguration(.init(hierarchicalColor: .secondaryLabelColor))
        } else {
            let image = NSImage(systemSymbolName: "escape", accessibilityDescription: "hypr")
            image?.isTemplate = true
            button.image = image
        }
        button.contentTintColor = nil
    }

    private func rebuildMenu() {
        let menu = NSMenu()
        menu.delegate = self

        if !isAccessibilityGranted {
            let infoItem = NSMenuItem(title: "Accessibility permission required", action: nil, keyEquivalent: "")
            infoItem.isEnabled = false
            menu.addItem(infoItem)
            menu.addItem(NSMenuItem(title: "Open System Settings…", action: #selector(openAccessibilitySettings), keyEquivalent: ""))
            menu.addItem(.separator())
        } else if isSecureInputActive {
            let infoItem = NSMenuItem(title: "Inactive: Secure Keyboard Entry is on", action: nil, keyEquivalent: "")
            infoItem.isEnabled = false
            menu.addItem(infoItem)
            menu.addItem(.separator())
        }

        let loginItem = NSMenuItem(
            title: "Launch at Login",
            action: #selector(toggleLaunchAtLogin),
            keyEquivalent: ""
        )
        loginItem.state = SMAppService.mainApp.status == .enabled ? .on : .off
        menu.addItem(loginItem)
        menu.addItem(.separator())
        menu.addItem(NSMenuItem(title: "About hypr", action: #selector(showAbout), keyEquivalent: ""))
        menu.addItem(.separator())
        menu.addItem(NSMenuItem(title: "Quit hypr", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))

        statusItem?.menu = menu
    }

    func menuWillOpen(_ menu: NSMenu) {
        menu.items.first(where: { $0.action == #selector(toggleLaunchAtLogin) })?.state =
            SMAppService.mainApp.status == .enabled ? .on : .off
    }

    @objc private func toggleLaunchAtLogin() {
        let service = SMAppService.mainApp
        if service.status == .enabled {
            try? service.unregister()
        } else {
            try? service.register()
        }
        rebuildMenu()
    }

    @objc private func showAbout() {
        if aboutWindowController == nil {
            aboutWindowController = AboutWindowController()
        }
        aboutWindowController?.show()
    }

    @objc private func openAccessibilitySettings() {
        NSWorkspace.shared.open(URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility")!)
    }

    private func registerLaunchAtLogin() {
        if SMAppService.mainApp.status == .notRegistered {
            try? SMAppService.mainApp.register()
        }
    }

    private func startStatusPolling() {
        statusTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.pollStatus()
        }
    }

    private func pollStatus() {
        let newAccessibility = AXIsProcessTrusted()
        let newSecureInput = IsSecureEventInputEnabled()

        let accessibilityChanged = newAccessibility != isAccessibilityGranted
        let secureInputChanged = newSecureInput != isSecureInputActive
        let wasSecureInputActive = isSecureInputActive

        isAccessibilityGranted = newAccessibility
        isSecureInputActive = newSecureInput

        if newAccessibility && handler == nil {
            startEventTap()
        }
        if wasSecureInputActive && !newSecureInput {
            handler?.reEnable()
        }

        if accessibilityChanged || secureInputChanged {
            updateStatusIcon()
            rebuildMenu()
        }
    }

    private func startEventTap() {
        let h = Handler()
        handler = h

        let mask: CGEventMask =
            1 << CGEventType.keyDown.rawValue
            | 1 << CGEventType.keyUp.rawValue

        guard let port = CGEvent.tapCreate(
            tap: .cgSessionEventTap,
            place: .headInsertEventTap,
            options: .defaultTap,
            eventsOfInterest: mask,
            callback: { proxy, type, event, refcon -> Unmanaged<CGEvent>? in
                Unmanaged<Handler>.fromOpaque(refcon!).takeUnretainedValue()
                    .handle(proxy: proxy, type: type, event: event, refcon: refcon)
            },
            userInfo: Unmanaged.passUnretained(h).toOpaque()
        ) else {
            handler = nil
            return
        }

        h.port = port
        let source = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, port, 0)
        CFRunLoopAddSource(CFRunLoopGetMain(), source, .commonModes)
        CGEvent.tapEnable(tap: port, enable: true)
    }
}
