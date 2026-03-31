import XCTest
@testable import StandUpApp

final class SessionTrackerTests: XCTestCase {
    func testReminderFiresOnceAfterWorkInterval() {
        var tracker = SessionTracker()
        let start = Date(timeIntervalSince1970: 1_000)

        _ = tracker.recordActivity(
            at: start,
            workIntervalSeconds: 10,
            idleResetSeconds: 5
        )

        let firstReminder = tracker.tick(
            at: start.addingTimeInterval(10),
            workIntervalSeconds: 10,
            idleResetSeconds: 5_000
        )

        XCTAssertEqual(firstReminder.state, .timeToStand)
        XCTAssertTrue(firstReminder.shouldNotify)

        let secondReminder = tracker.tick(
            at: start.addingTimeInterval(12),
            workIntervalSeconds: 10,
            idleResetSeconds: 5_000
        )

        XCTAssertEqual(secondReminder.state, .timeToStand)
        XCTAssertFalse(secondReminder.shouldNotify)
    }

    func testIdleGapResetsTheSession() {
        var tracker = SessionTracker()
        let start = Date(timeIntervalSince1970: 2_000)

        _ = tracker.recordActivity(
            at: start,
            workIntervalSeconds: 60,
            idleResetSeconds: 5
        )

        let idleSnapshot = tracker.tick(
            at: start.addingTimeInterval(6),
            workIntervalSeconds: 60,
            idleResetSeconds: 5
        )

        XCTAssertEqual(idleSnapshot.state, .waitingForActivity)
        XCTAssertEqual(idleSnapshot.elapsedSeconds, 0)
        XCTAssertNil(tracker.sessionStartedAt)
    }

    func testActivityAfterIdleStartsFreshSession() {
        var tracker = SessionTracker()
        let start = Date(timeIntervalSince1970: 3_000)

        _ = tracker.recordActivity(
            at: start,
            workIntervalSeconds: 60,
            idleResetSeconds: 5
        )

        _ = tracker.tick(
            at: start.addingTimeInterval(6),
            workIntervalSeconds: 60,
            idleResetSeconds: 5
        )

        let resumed = tracker.recordActivity(
            at: start.addingTimeInterval(7),
            workIntervalSeconds: 60,
            idleResetSeconds: 5
        )

        XCTAssertEqual(resumed.state, .tracking)
        XCTAssertEqual(resumed.elapsedSeconds, 0)
        XCTAssertEqual(tracker.sessionStartedAt, start.addingTimeInterval(7))
    }
}
