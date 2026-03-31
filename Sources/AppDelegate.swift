import AppKit

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {
    private let launchInstant = Date()
    private let settings = AppSettings()
    private lazy var reminderEngine = ReminderEngine(settings: settings)
    private var statusBarController: StatusBarController?

    func applicationDidFinishLaunching(_ notification: Notification) {
        guard !hasOlderMatchingPeer() else {
            NSApp.terminate(nil)
            return
        }

        NSApp.setActivationPolicy(.accessory)
        reminderEngine.start()
        statusBarController = StatusBarController(settings: settings, reminderEngine: reminderEngine)
    }

    private func hasOlderMatchingPeer() -> Bool {
        let currentProcessIdentifier = ProcessInfo.processInfo.processIdentifier
        let matchingApplications = NSWorkspace.shared.runningApplications.filter { application in
            guard application.processIdentifier != currentProcessIdentifier else {
                return false
            }

            if let bundleIdentifier = Bundle.main.bundleIdentifier,
               application.bundleIdentifier == bundleIdentifier {
                return true
            }

            guard let executablePath = Bundle.main.executableURL?.path else {
                return false
            }

            return application.executableURL?.path == executablePath
        }

        return matchingApplications.contains { application in
            if let launchDate = application.launchDate {
                if launchDate < launchInstant {
                    return true
                }

                if launchDate == launchInstant {
                    return application.processIdentifier < currentProcessIdentifier
                }
            }

            return application.processIdentifier < currentProcessIdentifier
        }
    }
}
