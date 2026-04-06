import SwiftUI

struct WorkHeatmapView: View {
    let snapshot: WorkHistorySnapshot
    let formatDuration: (TimeInterval) -> String

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("Work map")
                    .font(.headline)

                Spacer()

                Text("Last 12 weeks")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            HStack(spacing: 18) {
                metric(label: "Today", value: formatDuration(snapshot.todaySeconds))
                metric(label: "Streak", value: "\(snapshot.currentStreakDays)d")
                metric(label: "Best run", value: "\(snapshot.longestStreakDays)d")
            }

            heatmap

            HStack(spacing: 8) {
                Text("\(snapshot.activeDaysInRange) active days")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Text("·")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Text("Best day \(formatDuration(snapshot.bestDaySeconds))")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Spacer()

                legend
            }
        }
    }

    private var heatmap: some View {
        HStack(alignment: .top, spacing: 4) {
            ForEach(snapshot.weeks) { week in
                VStack(spacing: 4) {
                    ForEach(week.days) { day in
                        RoundedRectangle(cornerRadius: 3)
                            .fill(color(for: day))
                            .frame(width: 12, height: 12)
                    }
                }
            }
        }
        .padding(10)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.55))
        )
    }

    private var legend: some View {
        HStack(spacing: 4) {
            Text("Less")
                .font(.caption2)
                .foregroundStyle(.secondary)

            ForEach(0..<5, id: \.self) { level in
                RoundedRectangle(cornerRadius: 2)
                    .fill(color(for: level))
                    .frame(width: 8, height: 8)
            }

            Text("More")
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
    }

    private func metric(label: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(value)
                .font(.system(size: 15, weight: .semibold, design: .rounded))
                .foregroundStyle(StandUpTheme.heatmapPeak)

            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }

    private func color(for day: WorkDayCell) -> Color {
        guard !day.isFuture else {
            return StandUpTheme.heatmapFuture
        }

        return color(for: day.intensity)
    }

    private func color(for intensity: Int) -> Color {
        switch intensity {
        case 1:
            return StandUpTheme.heatmapLow
        case 2:
            return StandUpTheme.heatmapMedium
        case 3:
            return StandUpTheme.heatmapHigh
        case 4:
            return StandUpTheme.heatmapPeak
        default:
            return StandUpTheme.heatmapEmpty
        }
    }
}
