import Carbon.HIToolbox
import Cocoa

class Handler {
    let eventSource = CGEventSource.init(stateID: .privateState)
    let pid = getpid()

    var escDown = false

    func handle(
        proxy: CGEventTapProxy, type: CGEventType, event: CGEvent, refcon: UnsafeMutableRawPointer?
    ) -> Unmanaged<CGEvent>? {
        let eventSourcePid = event.getIntegerValueField(.eventSourceUnixProcessID)
        let keyCode = event.getIntegerValueField(.keyboardEventKeycode)

        switch type {
        case .keyUp where keyCode == kVK_Escape:
            escDown = false
            emitEscDown()
            return Unmanaged.passUnretained(event)
        case .keyDown where keyCode == kVK_Escape:
            if eventSourcePid == pid {
                return Unmanaged.passUnretained(event)
            } else {
                escDown = true
                return nil
            }
        case .keyUp, .keyDown:
            if escDown {
                setHyper(event: event)
            }
            return Unmanaged.passUnretained(event)
        default:
            return Unmanaged.passUnretained(event)
        }
    }

    func setHyper(event: CGEvent) {
        event.flags.insert(CGEventFlags.maskShift)
        event.flags.insert(CGEventFlags.maskControl)
        event.flags.insert(CGEventFlags.maskAlternate)
        event.flags.insert(CGEventFlags.maskCommand)
    }

    func emitEscDown() {
        let down = CGEvent.init(
            keyboardEventSource: eventSource, virtualKey: CGKeyCode(kVK_Escape),
            keyDown: true)
        down?.post(tap: .cghidEventTap)
    }
}
