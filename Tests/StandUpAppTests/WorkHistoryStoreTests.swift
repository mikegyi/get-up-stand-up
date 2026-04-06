import XCTest
@testable import StandUpApp

final class WorkHistoryStoreTests: XCTestCase {
    func testItAccumulatesDailyWorkAndCalculatesStreaks() {
        let (store, _) = makeStore()
        let today = date(year: 2026, month: 4, day: 6)
        let yesterday = date(year: 2026, month: 4, day: 5)

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
        let today = date(year: 2026, month: 4, day: 6)

        _ = store.recordActiveWork(seconds: 2_700, at: today)

        let reloadedStore = WorkHistoryStore(userDefaults: defaults, calendar: calendar)
        let snapshot = reloadedStore.snapshot(referenceDate: today)

        XCTAssertEqual(snapshot.todaySeconds, 2_700, accuracy: 0.001)
        XCTAssertEqual(snapshot.currentStreakDays, 1)
    }

    func testCurrentStreakStopsAtTheFirstGap() {
        let (store, _) = makeStore()

        _ = store.recordActiveWork(seconds: 3_600, at: date(year: 2026, month: 4, day: 3))
        _ = store.recordActiveWork(seconds: 3_600, at: date(year: 2026, month: 4, day: 4))
        _ = store.recordActiveWork(seconds: 3_600, at: date(year: 2026, month: 4, day: 6))

        let snapshot = store.snapshot(referenceDate: date(year: 2026, month: 4, day: 6))

        XCTAssertEqual(snapshot.currentStreakDays, 1)
        XCTAssertEqual(snapshot.longestStreakDays, 2)
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

    private var calendar: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        calendar.firstWeekday = 2
        return calendar
    }
}
