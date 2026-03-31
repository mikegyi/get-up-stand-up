import AppKit

final class ActivityMonitor {
    private var monitor: Any?

    func start(onActivity: @escaping () -> Void) {
        stop()

        let eventMask: NSEvent.EventTypeMask = [
            .keyDown,
            .leftMouseDown,
            .rightMouseDown,
            .otherMouseDown,
            .mouseMoved,
            .scrollWheel,
        ]

        monitor = NSEvent.addGlobalMonitorForEvents(matching: eventMask) { _ in
            onActivity()
        }
    }

    func stop() {
        guard let monitor else {
            return
        }

        NSEvent.removeMonitor(monitor)
        self.monitor = nil
    }

    deinit {
        stop()
    }
}
