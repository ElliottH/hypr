import Cocoa

func register(_ port: CFMachPort) {
    let source = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, port, 0)
    let current = CFRunLoopGetCurrent()
    CFRunLoopAddSource(current, source, .commonModes)
    CGEvent.tapEnable(tap: port, enable: true)
}

let handler = Handler()

func callback(
    proxy: CGEventTapProxy, type: CGEventType, event: CGEvent, refcon: UnsafeMutableRawPointer?
) -> Unmanaged<CGEvent>? {
    return handler.handle(proxy: proxy, type: type, event: event, refcon: refcon)
}

func main() {
    let prompt = kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String
    let options: NSDictionary = [prompt: true]
    if !AXIsProcessTrustedWithOptions(options) {
        print("Application requires accessibility permissions")
        exit(1)
    }

    let mask: CGEventMask =
        1 << CGEventType.keyDown.rawValue
        | 1 << CGEventType.keyUp.rawValue

    let port = CGEvent.tapCreate(
        tap: .cgSessionEventTap,
        place: .headInsertEventTap,
        options: .defaultTap,
        eventsOfInterest: mask,
        callback: callback,
        userInfo: nil
    )

    guard let port = port else {
        print("Failed to create event tap.")
        exit(1)
    }

    register(port)

    CFRunLoopRun()
}

main()
