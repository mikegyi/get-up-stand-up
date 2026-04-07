import XCTest
@testable import StandUpApp

final class WorkHistoryStoreTests: XCTestCase {
    func testItAccumulatesDailyWorkAndCalculatesStreaks() {
        let (store, _) = makeStore()
        let today = date(year: 2026, month: 4, day: 6, hour: 12, minute: 0)
        let yesterday = date(year: 2026, month: 4, day: 5, hour: 12, minute: 0)

        _ = store.recordActiveWork(seconds: 1_800, at: yesterday)
        let snapshot = store.recordActiveWork(seconds: 5_400, at: today)

        XCTAssertEqual(snapshot.todaySeconds, 5_400, accuracy: 0.001)
        XCTAssertEqual(snapshot.currentStreakDays, 2)
        XCTAssertEqual(snapshot.longestStreakDays, 2)
        XCTAssertEqual(snapshot.bestDaySeconds, 5_400, accuracy: 0.001)
        XCTAssertEqual(snapshot.activeDaysInRange, 2)
    }

    func testItPersistsAcrossStoreReloads() {
        let (store, defaults) = makeStore()
        let today = date(year: 2026, month: 4, day: 6, hour: 10, minute: 45)

        _ = store.recordActiveWork(seconds: 2_700, at: today)

        let reloadedStore = WorkHistoryStore(userDefaults: defaults, calendar: calendar)
        let snapshot = reloadedStore.snapshot(referenceDate: today)

        XCTAssertEqual(snapshot.todaySeconds, 2_700, accuracy: 0.001)
        XCTAssertEqual(snapshot.currentStreakDays, 1)
        XCTAssertEqual(snapshot.todayPatternSegments.count, 1)
    }

    func testCurrentStreakStopsAtTheFirstGap() {
        let (store, _) = makeStore()

        _ = store.recordActiveWork(seconds: 3_600, at: date(year: 2026, month: 4, day: 3, hour: 12, minute: 0))
        _ = store.recordActiveWork(seconds: 3_600, at: date(year: 2026, month: 4, day: 4, hour: 12, minute: 0))
        _ = store.recordActiveWork(seconds: 3_600, at: date(year: 2026, month: 4, day: 6, hour: 12, minute: 0))

        let snapshot = store.snapshot(referenceDate: date(year: 2026, month: 4, day: 6, hour: 12, minute: 0))

        XCTAssertEqual(snapshot.currentStreakDays, 1)
        XCTAssertEqual(snapshot.longestStreakDays, 2)
    }

    func testItBuildsMergedTodayPatternSegments() {
        let (store, _) = makeStore()
        let day = date(year: 2026, month: 4, day: 6)

        _ = store.recordActiveWork(seconds: 600, at: date(year: 2026, month: 4, day: 6, hour: 9, minute: 10))
        let snapshot = store.recordActiveWork(seconds: 600, at: date(year: 2026, month: 4, day: 6, hour: 9, minute: 20))

        XCTAssertEqual(snapshot.todayPatternSegments.count, 1)
        XCTAssertEqual(snapshot.todayPatternSegments[0].startFraction, (9 * 3_600) / 86_400, accuracy: 0.0001)
        XCTAssertEqual(snapshot.todayPatternSegments[0].endFraction, ((9 * 3_600) + (20 * 60)) / 86_400, accuracy: 0.0001)
        XCTAssertEqual(snapshot.todayNowFraction, ((9 * 3_600) + (20 * 60)) / 86_400, accuracy: 0.0001)
        XCTAssertEqual(snapshot.todaySeconds, 1_200, accuracy: 0.001)
        XCTAssertEqual(calendar.startOfDay(for: day), day)
    }

    func testItClampsTodayPatternAtStartOfDay() {
        let (store, _) = makeStore()
        let snapshot = store.recordActiveWork(
            seconds: 600,
            at: date(year: 2026, month: 4, day: 6, hour: 0, minute: 3)
        )

        XCTAssertEqual(snapshot.todayPatternSegments.count, 1)
        XCTAssertEqual(snapshot.todayPatternSegments[0].startFraction, 0, accuracy: 0.0001)
        XCTAssertEqual(snapshot.todayPatternSegments[0].endFraction, 180 / 86_400, accuracy: 0.0001)
    }

    func testItSplitsWorkAcrossMidnight() {
        let (store, _) = makeStore()

        _ = store.recordActiveWork(
            seconds: 2,
            at: date(year: 2026, month: 4, day: 7, hour: 0, minute: 0, second: 1)
        )

        let previousDaySnapshot = store.snapshot(
            referenceDate: date(year: 2026, month: 4, day: 6, hour: 23, minute: 59, second: 59)
        )
        let newDaySnapshot = store.snapshot(
            referenceDate: date(year: 2026, month: 4, day: 7, hour: 0, minute: 0, second: 1)
        )

        XCTAssertEqual(previousDaySnapshot.todaySeconds, 1, accuracy: 0.001)
        XCTAssertEqual(newDaySnapshot.todaySeconds, 1, accuracy: 0.001)
        XCTAssertEqual(previousDaySnapshot.todayPatternSegments.count, 1)
        XCTAssertEqual(newDaySnapshot.todayPatternSegments.count, 1)
        XCTAssertEqual(previousDaySnapshot.todayPatternSegments[0].startFraction, 86_398 / 86_400, accuracy: 0.0001)
        XCTAssertEqual(previousDaySnapshot.todayPatternSegments[0].endFraction, 1, accuracy: 0.0001)
        XCTAssertEqual(newDaySnapshot.todayPatternSegments[0].startFraction, 0, accuracy: 0.0001)
        XCTAssertEqual(newDaySnapshot.todayPatternSegments[0].endFraction, 1 / 86_400, accuracy: 0.0001)
    }

    private func makeStore() -> (WorkHistoryStore, UserDefaults) {
        let suiteName = "WorkHistoryStoreTests-\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suiteName)!
        defaults.removePersistentDomain(forName: suiteName)
        return (WorkHistoryStore(userDefaults: defaults, calendar: calendar), defaults)
    }

    private func date(year: Int, month: Int, day: Int) -> Date {
        calendar.date(from: DateComponents(year: year, month: month, day: day))!
    }

    private func date(year: Int, month: Int, day: Int, hour: Int, minute: Int) -> Date {
        calendar.date(from: DateComponents(year: year, month: month, day: day, hour: hour, minute: minute))!
    }

    private func date(year: Int, month: Int, day: Int, hour: Int, minute: Int, second: Int) -> Date {
        calendar.date(from: DateComponents(
            year: year,
            month: month,
            day: day,
            hour: hour,
            minute: minute,
            second: second
        ))!
    }

    private var calendar: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        calendar.firstWeekday = 2
        return calendar
    }
}
