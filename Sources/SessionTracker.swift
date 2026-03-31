import Foundation

struct SessionTracker {
    private(set) var sessionStartedAt: Date?
    private(set) var lastActivityAt: Date?
    private(set) var hasSentReminder = false

    mutating func recordActivity(
        at now: Date,
        workIntervalSeconds: TimeInterval,
        idleResetSeconds: TimeInterval
    ) -> SessionSnapshot {
        if let lastActivityAt, now.timeIntervalSince(lastActivityAt) >= idleResetSeconds {
            sessionStartedAt = now
            hasSentReminder = false
        }

        if sessionStartedAt == nil {
            sessionStartedAt = now
            hasSentReminder = false
        }

        lastActivityAt = now

        return tick(
            at: now,
            workIntervalSeconds: workIntervalSeconds,
            idleResetSeconds: idleResetSeconds
        )
    }

    mutating func tick(
        at now: Date,
        workIntervalSeconds: TimeInterval,
        idleResetSeconds: TimeInterval
    ) -> SessionSnapshot {
        guard let sessionStartedAt, let lastActivityAt else {
            return SessionSnapshot(elapsedSeconds: 0, state: .waitingForActivity, shouldNotify: false)
        }

        if now.timeIntervalSince(lastActivityAt) >= idleResetSeconds {
            reset()
            return SessionSnapshot(elapsedSeconds: 0, state: .waitingForActivity, shouldNotify: false)
        }

        let elapsedSeconds = now.timeIntervalSince(sessionStartedAt)
        guard elapsedSeconds >= workIntervalSeconds else {
            return SessionSnapshot(elapsedSeconds: elapsedSeconds, state: .tracking, shouldNotify: false)
        }

        if hasSentReminder {
            return SessionSnapshot(elapsedSeconds: elapsedSeconds, state: .timeToStand, shouldNotify: false)
        }

        hasSentReminder = true
        return SessionSnapshot(elapsedSeconds: elapsedSeconds, state: .timeToStand, shouldNotify: true)
    }

    mutating func reset() {
        sessionStartedAt = nil
        lastActivityAt = nil
        hasSentReminder = false
    }
}

struct SessionSnapshot {
    let elapsedSeconds: TimeInterval
    let state: SessionState
    let shouldNotify: Bool
}
