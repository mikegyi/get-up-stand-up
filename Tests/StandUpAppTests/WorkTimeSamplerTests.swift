import XCTest
@testable import StandUpApp

final class WorkTimeSamplerTests: XCTestCase {
    func testFreshSessionResetsSamplingBaselineAfterLongGap() {
        var sampler = WorkTimeSampler()
        let start = Date(timeIntervalSince1970: 10_000)

        XCTAssertNil(
            sampler.sample(
                at: start,
                sessionState: .tracking,
                elapsedSeconds: 0,
                shouldRecordWork: false
            )
        )

        let firstTrackedSecond = sampler.sample(
            at: start.addingTimeInterval(1),
            sessionState: .tracking,
            elapsedSeconds: 1,
            shouldRecordWork: true
        )
        XCTAssertNotNil(firstTrackedSecond)
        XCTAssertEqual(firstTrackedSecond ?? 0, 1, accuracy: 0.001)

        XCTAssertNil(
            sampler.sample(
                at: start.addingTimeInterval(1_200),
                sessionState: .tracking,
                elapsedSeconds: 0,
                shouldRecordWork: false
            )
        )

        let resumedTrackedSecond = sampler.sample(
            at: start.addingTimeInterval(1_201),
            sessionState: .tracking,
            elapsedSeconds: 1,
            shouldRecordWork: true
        )
        XCTAssertNotNil(resumedTrackedSecond)
        XCTAssertEqual(resumedTrackedSecond ?? 0, 1, accuracy: 0.001)
    }

    func testNonTrackingStateClearsSamplingBaseline() {
        var sampler = WorkTimeSampler()
        let start = Date(timeIntervalSince1970: 20_000)

        _ = sampler.sample(
            at: start,
            sessionState: .tracking,
            elapsedSeconds: 0,
            shouldRecordWork: false
        )

        _ = sampler.sample(
            at: start.addingTimeInterval(5),
            sessionState: .tracking,
            elapsedSeconds: 5,
            shouldRecordWork: true
        )

        XCTAssertNil(
            sampler.sample(
                at: start.addingTimeInterval(600),
                sessionState: .waitingForActivity,
                elapsedSeconds: 0,
                shouldRecordWork: true
            )
        )

        XCTAssertNil(
            sampler.sample(
                at: start.addingTimeInterval(601),
                sessionState: .tracking,
                elapsedSeconds: 0,
                shouldRecordWork: false
            )
        )

        let secondFreshTick = sampler.sample(
            at: start.addingTimeInterval(602),
            sessionState: .tracking,
            elapsedSeconds: 1,
            shouldRecordWork: true
        )
        XCTAssertNotNil(secondFreshTick)
        XCTAssertEqual(secondFreshTick ?? 0, 1, accuracy: 0.001)
    }
}
