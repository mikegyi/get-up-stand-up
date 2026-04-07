import SwiftUI

enum StandUpTheme {
    static let green = Color(red: 0.12, green: 0.49, blue: 0.23)
    static let brightGreen = Color(red: 0.18, green: 0.67, blue: 0.30)
    static let gold = Color(red: 0.95, green: 0.76, blue: 0.16)
    static let red = Color(red: 0.77, green: 0.16, blue: 0.20)
    static let background = Color(red: 0.98, green: 0.96, blue: 0.90)
    static let timelineBreak = Color(red: 0.83, green: 0.81, blue: 0.75)
    static let timelineFuture = Color(red: 0.92, green: 0.91, blue: 0.87)
    static let timelineNow = Color(red: 0.74, green: 0.20, blue: 0.24)
    static let heatmapEmpty = Color(red: 0.89, green: 0.87, blue: 0.81)
    static let heatmapFuture = Color(red: 0.95, green: 0.94, blue: 0.90)
    static let heatmapLow = Color(red: 0.72, green: 0.85, blue: 0.68)
    static let heatmapMedium = Color(red: 0.47, green: 0.71, blue: 0.40)
    static let heatmapHigh = Color(red: 0.24, green: 0.57, blue: 0.27)
    static let heatmapPeak = Color(red: 0.10, green: 0.37, blue: 0.18)

    static let gradient = LinearGradient(
        colors: [green, gold, red],
        startPoint: .leading,
        endPoint: .trailing
    )
}
