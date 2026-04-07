import SwiftUI

struct WorkDayPatternLineView: View {
    let segments: [WorkPatternSegment]
    let nowFraction: Double

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(StandUpTheme.timelineFuture)

                Capsule()
                    .fill(StandUpTheme.timelineBreak)
                    .frame(width: max(geometry.size.width * nowFraction, 0))

                ForEach(segments) { segment in
                    Capsule()
                        .fill(StandUpTheme.heatmapPeak)
                        .frame(
                            width: max((segment.endFraction - segment.startFraction) * geometry.size.width, 2),
                            height: geometry.size.height
                        )
                        .offset(x: segment.startFraction * geometry.size.width)
                }

                Capsule()
                    .fill(StandUpTheme.timelineNow)
                    .frame(width: 2, height: geometry.size.height + 2)
                    .offset(x: max((geometry.size.width * nowFraction) - 1, 0))
            }
        }
    }
}
