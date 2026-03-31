import ApplicationServices

enum InputAccessState: String {
    case granted = "Activity tracking is enabled"
    case needsApproval = "Allow Input Monitoring for keyboard tracking"
}

struct InputAccessMonitor {
    func currentState() -> InputAccessState {
        CGPreflightListenEventAccess() ? .granted : .needsApproval
    }

    func requestAccess() {
        _ = CGRequestListenEventAccess()
    }
}
