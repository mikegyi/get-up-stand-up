import Foundation

@MainActor
final class AppSettings: ObservableObject {
    @Published var workIntervalMinutes: Double {
        didSet {
            UserDefaults.standard.set(workIntervalMinutes, forKey: Keys.workIntervalMinutes)
        }
    }

    @Published var idleResetMinutes: Double {
        didSet {
            UserDefaults.standard.set(idleResetMinutes, forKey: Keys.idleResetMinutes)
        }
    }

    init() {
        let defaults = UserDefaults.standard

        let savedWorkInterval = defaults.object(forKey: Keys.workIntervalMinutes) as? Double
        let savedIdleReset = defaults.object(forKey: Keys.idleResetMinutes) as? Double

        workIntervalMinutes = savedWorkInterval ?? 45
        idleResetMinutes = savedIdleReset ?? 3
    }
}

private enum Keys {
    static let workIntervalMinutes = "workIntervalMinutes"
    static let idleResetMinutes = "idleResetMinutes"
}
