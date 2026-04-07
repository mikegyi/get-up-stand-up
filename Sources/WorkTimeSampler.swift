import Foundation

struct WorkTimeSampler {
    private(set) var lastSampleAt: Date?

    mutating func sample(
        at now: Date,
        sessionState: SessionState,
        elapsedSeconds: TimeInterval,
        shouldRecordWork: Bool
    ) -> TimeInterval? {
        guard sessionState == .tracking || sessionState == .timeToStand else {
            lastSampleAt = nil
            return nil
        }

        guard shouldRecordWork else {
            if elapsedSeconds == 0 || lastSampleAt == nil {
                lastSampleAt = now
            }

            return nil
        }

        guard let lastSampleAt else {
            self.lastSampleAt = now
            return nil
        }

        self.lastSampleAt = now
        return max(now.timeIntervalSince(lastSampleAt), 0)
    }
}
