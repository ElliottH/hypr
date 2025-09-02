import Carbon.HIToolbox
import Cocoa

class Handler {
    let pid = Int64(getpid())

    var escDown = false
    var escEvent: CGEvent? = nil

    func handle(
        proxy: CGEventTapProxy, type: CGEventType, event: CGEvent, refcon: UnsafeMutableRawPointer?
    ) -> Unmanaged<CGEvent>? {
        let eventSourcePid = event.getIntegerValueField(.eventSourceUnixProcessID)
        let keyCode = event.getIntegerValueField(.keyboardEventKeycode)

        switch type {
        case .keyUp where keyCode == kVK_Escape:
            escDown = false

            if let down = escEvent {
                // Emit the down first, then the up
                down.setIntegerValueField(.eventSourceUnixProcessID, value: pid)
                down.post(tap: .cghidEventTap)
                escEvent = nil
                return Unmanaged.passUnretained(event)
            } else {
                // Emit nothing. We were acting as modifier keys
                return nil
            }
        case .keyDown where keyCode == kVK_Escape:
            if eventSourcePid == pid {
                // Leave our escape keyDown's alone
                return Unmanaged.passUnretained(event)
            } else {
                escDown = true
                escEvent = event
                return nil
            }
        case .keyUp, .keyDown:
            if escDown {
                setHyper(event: event)
            }

            // If we're used as hyper, then we're not escape, so we won't emit
            // escape keypresses for this press
            escEvent = nil
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
}
