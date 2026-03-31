import SwiftUI

struct MenuBarLabelView: View {
    @ObservedObject var reminderEngine: ReminderEngine

    var body: some View {
        HStack(spacing: 4) {
            Text("🟥🟨🟩")
                .font(.system(size: 10))

            Text(reminderEngine.menuBarTimerText())
                .font(.system(size: 12, weight: .black, design: .rounded))
                .monospacedDigit()
                .foregroundStyle(reminderEngine.sessionState == .timeToStand ? StandUpTheme.red : Color.primary)
        }
        .padding(.horizontal, 6)
        .padding(.vertical, 1)
        .background(backgroundColor, in: Capsule())
    }

    private var backgroundColor: Color {
        switch reminderEngine.sessionState {
        case .timeToStand:
            return StandUpTheme.gold.opacity(0.55)
        case .paused:
            return StandUpTheme.red.opacity(0.14)
        default:
            return StandUpTheme.green.opacity(0.12)
        }
    }
}
