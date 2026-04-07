import SwiftUI

struct WorkDayPatternLineView: View {
    let segments: [WorkPatternSegment]

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(StandUpTheme.timelineTrack)

                ForEach(segments) { segment in
                    Capsule()
                        .fill(StandUpTheme.heatmapPeak)
                        .frame(
                            width: max((segment.endFraction - segment.startFraction) * geometry.size.width, 2),
                            height: geometry.size.height
                        )
                        .offset(x: segment.startFraction * geometry.size.width)
                }
            }
        }
    }
}
