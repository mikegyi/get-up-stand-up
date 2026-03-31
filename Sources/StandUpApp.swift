import SwiftUI

@main
struct StandUpApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    @StateObject private var settings: AppSettings
    @StateObject private var reminderEngine: ReminderEngine

    init() {
        let settings = AppSettings()
        let reminderEngine = ReminderEngine(settings: settings)
        reminderEngine.start()

        _settings = StateObject(wrappedValue: settings)
        _reminderEngine = StateObject(wrappedValue: reminderEngine)
    }

    var body: some Scene {
        MenuBarExtra {
            MenuBarView(reminderEngine: reminderEngine, settings: settings)
        } label: {
            Text(reminderEngine.menuBarLabelText())
                .monospacedDigit()
        }
        .menuBarExtraStyle(.window)
    }
}
