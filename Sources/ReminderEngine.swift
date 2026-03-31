import Foundation

@MainActor
final class ReminderEngine: ObservableObject {
    @Published private(set) var elapsedSeconds: TimeInterval = 0
    @Published private(set) var sessionState: SessionState = .waitingForActivity
    @Published var isPaused = false

    private let settings: AppSettings
    private let activityMonitor = ActivityMonitor()
    private let notifier = ReminderNotifier()
    private let speaker = ReminderSpeaker()

    private var timer: Timer?
    private var hasStarted = false
    private var tracker = SessionTracker()

    init(settings: AppSettings) {
        self.settings = settings
    }

    func start() {
        guard !hasStarted else {
            return
        }

        hasStarted = true
        notifier.requestAuthorization()

        activityMonitor.start { [weak self] in
            Task { @MainActor in
                self?.recordActivity()
            }
        }

        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.tick()
            }
        }

        tick()
    }

    func pause() {
        isPaused = true
        sessionState = .paused
    }

    func resume() {
        isPaused = false
        sessionState = tracker.sessionStartedAt == nil ? .waitingForActivity : .tracking
        recordActivity()
    }

    func resetSession() {
        tracker.reset()
        elapsedSeconds = 0
        sessionState = isPaused ? .paused : .waitingForActivity
    }

    func formattedElapsed() -> String {
        let totalSeconds = Int(elapsedSeconds)
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    func reminderProgress() -> Double {
        let targetSeconds = settings.workIntervalMinutes * 60
        guard targetSeconds > 0 else {
            return 0
        }

        return min(elapsedSeconds / targetSeconds, 1)
    }

    private func recordActivity() {
        guard !isPaused else {
            return
        }

        let snapshot = tracker.recordActivity(
            at: Date(),
            workIntervalSeconds: settings.workIntervalMinutes * 60,
            idleResetSeconds: settings.idleResetMinutes * 60
        )

        apply(snapshot)
    }

    private func tick() {
        guard !isPaused else {
            return
        }

        let snapshot = tracker.tick(
            at: Date(),
            workIntervalSeconds: settings.workIntervalMinutes * 60,
            idleResetSeconds: settings.idleResetMinutes * 60
        )

        apply(snapshot)
    }

    private func apply(_ snapshot: SessionSnapshot) {
        elapsedSeconds = snapshot.elapsedSeconds
        sessionState = snapshot.state

        guard snapshot.shouldNotify else {
            return
        }

        notifier.sendStandUpReminder()
        speaker.speakReminder()
    }
}

enum SessionState: String {
    case waitingForActivity = "Waiting for activity"
    case tracking = "Tracking your coding streak"
    case paused = "Paused"
    case timeToStand = "Time to stand up"
}
