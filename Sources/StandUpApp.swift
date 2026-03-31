import SwiftUI

@main
struct StandUpApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    @StateObject private var settings: AppSettings
    @StateObject private var reminderEngine: ReminderEngine

    init() {
        let settings = AppSettings()
        _settings = StateObject(wrappedValue: settings)
        _reminderEngine = StateObject(wrappedValue: ReminderEngine(settings: settings))
    }

    var body: some Scene {
        MenuBarExtra {
            MenuBarView(reminderEngine: reminderEngine, settings: settings)
                .onAppear {
                    reminderEngine.start()
                }
        } label: {
            Text(reminderEngine.menuBarLabelText())
                .monospacedDigit()
        }
        .menuBarExtraStyle(.window)
    }
}
