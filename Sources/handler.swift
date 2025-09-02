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
        if eventSourcePid == pid {
            // Leave any events that we have emitted alone
            return Unmanaged.passUnretained(event)
        }

        let keyCode = event.getIntegerValueField(.keyboardEventKeycode)
        switch type {
        case .keyUp where keyCode == kVK_Escape:
            escDown = false

            if let down = escEvent {
                // Emit the down first, then the up
                down.setIntegerValueField(.eventSourceUnixProcessID, value: pid)
                down.post(tap: .cghidEventTap)
                escEvent = nil

                // We have to post the keyUp event, rather than returning it,
                // otherwise it can get reordered and appear before the keyDown!
                event.setIntegerValueField(.eventSourceUnixProcessID, value: pid)
                event.post(tap: .cghidEventTap)
                return nil
            } else {
                // Emit nothing. We were acting as modifier keys
                return nil
            }
        case .keyDown where keyCode == kVK_Escape:
            // Real escape keyDown, store it for later
            escDown = true
            escEvent = event
            return nil
        case .keyUp, .keyDown:
            // If we're used as hyper, then we're not escape, so we won't emit
            // escape keypresses for this press
            escEvent = nil
            return Unmanaged.passUnretained(setHyper(event))
        default:
            return Unmanaged.passUnretained(event)
        }
    }

    func setHyper(_ event: CGEvent) -> CGEvent {
        if escDown {
            event.flags.insert(CGEventFlags.maskShift)
            event.flags.insert(CGEventFlags.maskControl)
            event.flags.insert(CGEventFlags.maskAlternate)
            event.flags.insert(CGEventFlags.maskCommand)
        }
        return event
    }
}
