@preconcurrency import ApplicationServices

enum InputAccessState: String {
    case granted = "Activity tracking is enabled"
    case needsApproval = "Mouse tracking works now. Enable Accessibility for keyboard tracking too."
}

struct InputAccessMonitor {
    func currentState() -> InputAccessState {
        AXIsProcessTrusted() ? .granted : .needsApproval
    }

    func requestAccess() {
        let options = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: true] as CFDictionary
        _ = AXIsProcessTrustedWithOptions(options)
    }
}
