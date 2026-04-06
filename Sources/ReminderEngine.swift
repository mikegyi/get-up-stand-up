import Foundation

@MainActor
final class ReminderEngine: ObservableObject {
    @Published private(set) var elapsedSeconds: TimeInterval = 0
    @Published private(set) var sessionState: SessionState = .waitingForActivity
    @Published private(set) var inputAccessState: InputAccessState = .needsApproval
    @Published private(set) var workHistory: WorkHistorySnapshot
    @Published var isPaused = false

    private let settings: AppSettings
    private let workHistoryStore = WorkHistoryStore()
    private let activityMonitor = ActivityMonitor()
    private let inputAccessMonitor = InputAccessMonitor()
    private let notifier = ReminderNotifier()

    private var timer: Timer?
    private var hasStarted = false
    private var tracker = SessionTracker()
    private var lastWorkSampleAt: Date?

    init(settings: AppSettings) {
        self.settings = settings
        workHistory = workHistoryStore.snapshot()
    }

    func start() {
        guard !hasStarted else {
            return
        }

        hasStarted = true
        refreshInputAccess()
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

    func refreshInputAccess() {
        inputAccessState = inputAccessMonitor.currentState()
    }

    func requestInputAccess() {
        inputAccessMonitor.requestAccess()
        refreshInputAccess()
    }

    func pause() {
        isPaused = true
        sessionState = .paused
        lastWorkSampleAt = nil
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
        lastWorkSampleAt = nil
    }

    func formattedElapsed() -> String {
        format(minutesAndSecondsFor: elapsedSeconds)
    }

    func menuBarLabelText() -> String {
        switch sessionState {
        case .waitingForActivity:
            return "🎶 00:00"
        case .paused:
            return "⏸ \(formattedElapsed())"
        case .tracking:
            return "🎶 \(formattedElapsed())"
        case .timeToStand:
            return "💿 \(formattedElapsed())"
        }
    }

    func formattedWorkDuration(_ totalTime: TimeInterval) -> String {
        let totalSeconds = max(Int(totalTime.rounded()), 0)
        let hours = totalSeconds / 3_600
        let minutes = (totalSeconds % 3_600) / 60

        if hours > 0 {
            return minutes > 0 ? "\(hours)h \(minutes)m" : "\(hours)h"
        }

        if minutes > 0 {
            return "\(minutes)m"
        }

        return "\(totalSeconds)s"
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

        let now = Date()
        let snapshot = tracker.recordActivity(
            at: now,
            workIntervalSeconds: settings.workIntervalMinutes * 60,
            idleResetSeconds: settings.idleResetMinutes * 60
        )

        apply(snapshot, at: now, shouldRecordWork: false)
    }

    private func tick() {
        guard !isPaused else {
            return
        }

        let now = Date()
        let snapshot = tracker.tick(
            at: now,
            workIntervalSeconds: settings.workIntervalMinutes * 60,
            idleResetSeconds: settings.idleResetMinutes * 60
        )

        apply(snapshot, at: now, shouldRecordWork: true)
    }

    private func apply(_ snapshot: SessionSnapshot, at now: Date, shouldRecordWork: Bool) {
        elapsedSeconds = snapshot.elapsedSeconds
        sessionState = snapshot.state
        refreshWorkHistory(at: now, state: snapshot.state, shouldRecordWork: shouldRecordWork)

        guard snapshot.shouldNotify else {
            return
        }

        notifier.sendStandUpReminder()
    }

    private func refreshWorkHistory(at now: Date, state: SessionState, shouldRecordWork: Bool) {
        guard state == .tracking || state == .timeToStand else {
            lastWorkSampleAt = nil
            workHistory = workHistoryStore.snapshot(referenceDate: now)
            return
        }

        guard shouldRecordWork else {
            workHistory = workHistoryStore.snapshot(referenceDate: now)
            return
        }

        defer {
            lastWorkSampleAt = now
        }

        guard let lastWorkSampleAt else {
            workHistory = workHistoryStore.snapshot(referenceDate: now)
            return
        }

        let seconds = max(now.timeIntervalSince(lastWorkSampleAt), 0)
        workHistory = workHistoryStore.recordActiveWork(seconds: seconds, at: now)
    }

    private func format(minutesAndSecondsFor totalTime: TimeInterval) -> String {
        let totalSeconds = max(Int(totalTime), 0)
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

enum SessionState: String {
    case waitingForActivity = "Waiting for the groove"
    case tracking = "Coding streak in progress"
    case paused = "Paused"
    case timeToStand = "Get up stand up 🎶"
}
