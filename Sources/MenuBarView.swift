import SwiftUI

struct MenuBarView: View {
    @ObservedObject var reminderEngine: ReminderEngine
    @ObservedObject var settings: AppSettings

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            header

            VStack(alignment: .leading, spacing: 6) {
                Text(reminderEngine.formattedElapsed())
                    .font(.system(size: 34, weight: .bold, design: .rounded))
                    .foregroundStyle(StandUpTheme.gradient)

                Text("your current coding streak")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                ProgressView(value: reminderEngine.reminderProgress())
                    .progressViewStyle(.linear)
                    .tint(StandUpTheme.green)
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("Work interval: \(Int(settings.workIntervalMinutes)) min")
                Slider(value: $settings.workIntervalMinutes, in: 15...90, step: 5)
                    .tint(StandUpTheme.gold)

                Text("Idle reset: \(Int(settings.idleResetMinutes)) min")
                Slider(value: $settings.idleResetMinutes, in: 1...10, step: 1)
                    .tint(StandUpTheme.red)
            }

            Divider()

            if reminderEngine.inputAccessState == .needsApproval {
                Button("Enable keyboard tracking in Accessibility") {
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
        .frame(width: 320)
        .background(StandUpTheme.background)
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Get Up Stand Up 🎶")
                .font(.title3.weight(.bold))
                .foregroundStyle(StandUpTheme.gradient)

            Text(reminderEngine.sessionState.rawValue)
                .font(.headline)

            Text(reminderEngine.inputAccessState.rawValue)
                .font(.caption)
                .foregroundStyle(.secondary)

            HStack(spacing: 6) {
                themeStripe(StandUpTheme.green)
                themeStripe(StandUpTheme.gold)
                themeStripe(StandUpTheme.red)
            }
        }
    }

    private func themeStripe(_ color: Color) -> some View {
        RoundedRectangle(cornerRadius: 999)
            .fill(color)
            .frame(height: 6)
    }
}
