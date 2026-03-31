import SwiftUI

struct MenuBarView: View {
    @ObservedObject var reminderEngine: ReminderEngine
    @ObservedObject var settings: AppSettings

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text(reminderEngine.sessionState.rawValue)
                .font(.headline)

            Text(reminderEngine.inputAccessState.rawValue)
                .font(.caption)
                .foregroundStyle(.secondary)

            VStack(alignment: .leading, spacing: 6) {
                Text(reminderEngine.formattedElapsed())
                    .font(.system(size: 32, weight: .bold, design: .rounded))

                ProgressView(value: reminderEngine.reminderProgress())
                    .progressViewStyle(.linear)
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("Work interval: \(Int(settings.workIntervalMinutes)) min")
                Slider(value: $settings.workIntervalMinutes, in: 15...90, step: 5)

                Text("Idle reset: \(Int(settings.idleResetMinutes)) min")
                Slider(value: $settings.idleResetMinutes, in: 1...10, step: 1)
            }

            Divider()

            if reminderEngine.inputAccessState == .needsApproval {
                Button("Open Input Monitoring Prompt") {
                    reminderEngine.requestInputAccess()
                }
            }

            Button(reminderEngine.isPaused ? "Resume tracking" : "Pause tracking") {
                if reminderEngine.isPaused {
                    reminderEngine.resume()
                } else {
                    reminderEngine.pause()
                }
            }

            Button("Reset timer") {
                reminderEngine.resetSession()
            }

            Button("Quit") {
                NSApplication.shared.terminate(nil)
            }
        }
        .padding(16)
        .frame(width: 280)
    }
}
