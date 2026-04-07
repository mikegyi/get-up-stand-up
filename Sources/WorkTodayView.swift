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

            WorkDayPatternLineView(segments: snapshot.todayPatternSegments)
                .frame(height: 8)
            
            if snapshot.todaySeconds == 0 {
                Text("No tracked work yet today")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }
}
