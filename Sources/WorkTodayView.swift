import SwiftUI

struct WorkTodayView: View {
    let snapshot: WorkHistorySnapshot
    let formatDuration: (TimeInterval) -> String

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("Today")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Spacer()
            }

            Text(formatDuration(snapshot.todaySeconds))
                .font(.system(size: 24, weight: .semibold, design: .rounded))
                .foregroundStyle(StandUpTheme.heatmapPeak)

            WorkDayPatternLineView(
                segments: snapshot.todayPatternSegments,
                nowFraction: snapshot.todayNowFraction
            )
                .frame(height: 10)

            WorkTodayLegendView()
            
            if snapshot.todaySeconds == 0 {
                Text("No tracked work yet today")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

private struct WorkTodayLegendView: View {
    var body: some View {
        HStack(spacing: 10) {
            legendItem(color: StandUpTheme.brightGreen, label: "Work")
            legendItem(color: StandUpTheme.timelineBreak, label: "Break")
            legendItem(color: StandUpTheme.timelineNow, label: "Now")
            Spacer()
        }
    }

    private func legendItem(color: Color, label: String) -> some View {
        HStack(spacing: 4) {
            Capsule()
                .fill(color)
                .frame(width: 12, height: 5)

            Text(label)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
    }
}
