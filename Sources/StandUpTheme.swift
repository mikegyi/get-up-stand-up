import SwiftUI

enum StandUpTheme {
    static let green = Color(red: 0.12, green: 0.49, blue: 0.23)
    static let gold = Color(red: 0.95, green: 0.76, blue: 0.16)
    static let red = Color(red: 0.77, green: 0.16, blue: 0.20)
    static let background = Color(red: 0.98, green: 0.96, blue: 0.90)

    static let gradient = LinearGradient(
        colors: [green, gold, red],
        startPoint: .leading,
        endPoint: .trailing
    )
}
