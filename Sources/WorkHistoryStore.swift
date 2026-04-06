import Foundation

struct WorkDayCell: Identifiable, Equatable {
    let id: String
    let date: Date
    let activeSeconds: TimeInterval
    let intensity: Int
    let isFuture: Bool
}

struct WorkWeek: Identifiable, Equatable {
    let id: String
    let days: [WorkDayCell]
}

struct WorkHistorySnapshot: Equatable {
    let weeks: [WorkWeek]
    let todaySeconds: TimeInterval
    let currentStreakDays: Int
    let longestStreakDays: Int
    let bestDaySeconds: TimeInterval
    let activeDaysInRange: Int

    static let empty = WorkHistorySnapshot(
        weeks: [],
        todaySeconds: 0,
        currentStreakDays: 0,
        longestStreakDays: 0,
        bestDaySeconds: 0,
        activeDaysInRange: 0
    )
}

final class WorkHistoryStore {
    private let userDefaults: UserDefaults
    private var calendar: Calendar
    private var activeSecondsByDay: [String: TimeInterval]
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    init(
        userDefaults: UserDefaults = .standard,
        calendar: Calendar = .autoupdatingCurrent
    ) {
        self.userDefaults = userDefaults
        self.calendar = calendar
        activeSecondsByDay = Self.loadHistory(from: userDefaults, using: decoder)
    }

    func recordActiveWork(seconds: TimeInterval, at date: Date = Date()) -> WorkHistorySnapshot {
        guard seconds > 0 else {
            return snapshot(referenceDate: date)
        }

        let dayKey = key(for: date)
        activeSecondsByDay[dayKey, default: 0] += seconds
        trimHistory(relativeTo: date)
        persist()

        return snapshot(referenceDate: date)
    }

    func snapshot(referenceDate: Date = Date(), weeks: Int = 12) -> WorkHistorySnapshot {
        let endDay = calendar.startOfDay(for: referenceDate)
        guard let gridStart = startOfDisplayedRange(endingAt: endDay, weeks: weeks) else {
            return .empty
        }

        let currentWeekStart = startOfWeek(for: endDay)
        let gridEnd = calendar.date(byAdding: .day, value: 6, to: currentWeekStart) ?? endDay

        var displayedDates: [Date] = []
        var weeksOutput: [WorkWeek] = []

        for weekIndex in 0..<weeks {
            guard let weekStart = calendar.date(byAdding: .day, value: weekIndex * 7, to: gridStart) else {
                continue
            }

            let rawCells = (0..<7).compactMap { dayOffset -> (date: Date, seconds: TimeInterval, isFuture: Bool)? in
                guard let date = calendar.date(byAdding: .day, value: dayOffset, to: weekStart) else {
                    return nil
                }

                let isFuture = date > endDay
                let seconds = isFuture ? 0 : activeSeconds(on: date)
                displayedDates.append(date)
                return (date: date, seconds: seconds, isFuture: isFuture)
            }

            weeksOutput.append(
                WorkWeek(
                    id: key(for: weekStart),
                    days: rawCells.map { cell in
                        WorkDayCell(
                            id: key(for: cell.date),
                            date: cell.date,
                            activeSeconds: cell.seconds,
                            intensity: 0,
                            isFuture: cell.isFuture
                        )
                    }
                )
            )
        }

        let nonFutureCells = weeksOutput
            .flatMap(\.days)
            .filter { !$0.isFuture }
        let maxDaySeconds = nonFutureCells.map(\.activeSeconds).max() ?? 0

        let normalizedWeeks = weeksOutput.map { week in
            WorkWeek(
                id: week.id,
                days: week.days.map { day in
                    WorkDayCell(
                        id: day.id,
                        date: day.date,
                        activeSeconds: day.activeSeconds,
                        intensity: intensity(for: day.activeSeconds, maxDaySeconds: maxDaySeconds),
                        isFuture: day.isFuture
                    )
                }
            )
        }

        let rangeDates = displayedDates.filter { $0 >= gridStart && $0 <= gridEnd && $0 <= endDay }

        return WorkHistorySnapshot(
            weeks: normalizedWeeks,
            todaySeconds: activeSeconds(on: endDay),
            currentStreakDays: currentStreak(endingAt: endDay),
            longestStreakDays: longestStreak(across: rangeDates),
            bestDaySeconds: maxDaySeconds,
            activeDaysInRange: nonFutureCells.filter { $0.activeSeconds > 0 }.count
        )
    }

    private func activeSeconds(on date: Date) -> TimeInterval {
        activeSecondsByDay[key(for: date)] ?? 0
    }

    private func currentStreak(endingAt endDay: Date) -> Int {
        var streak = 0
        var cursor = endDay

        while activeSeconds(on: cursor) > 0 {
            streak += 1
            guard let previousDay = calendar.date(byAdding: .day, value: -1, to: cursor) else {
                break
            }

            cursor = previousDay
        }

        return streak
    }

    private func longestStreak(across dates: [Date]) -> Int {
        let sortedDates = dates.sorted()
        var best = 0
        var current = 0

        for date in sortedDates {
            if activeSeconds(on: date) > 0 {
                current += 1
                best = max(best, current)
            } else {
                current = 0
            }
        }

        return best
    }

    private func intensity(for seconds: TimeInterval, maxDaySeconds: TimeInterval) -> Int {
        guard seconds > 0, maxDaySeconds > 0 else {
            return 0
        }

        let ratio = seconds / maxDaySeconds

        switch ratio {
        case ..<0.25:
            return 1
        case ..<0.5:
            return 2
        case ..<0.75:
            return 3
        default:
            return 4
        }
    }

    private func startOfDisplayedRange(endingAt endDay: Date, weeks: Int) -> Date? {
        let currentWeekStart = startOfWeek(for: endDay)
        return calendar.date(byAdding: .day, value: -((weeks - 1) * 7), to: currentWeekStart)
    }

    private func startOfWeek(for date: Date) -> Date {
        let components = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: date)
        return calendar.date(from: components).map(calendar.startOfDay(for:)) ?? calendar.startOfDay(for: date)
    }

    private func trimHistory(relativeTo referenceDate: Date) {
        guard let cutoff = calendar.date(byAdding: .day, value: -365, to: calendar.startOfDay(for: referenceDate)) else {
            return
        }

        activeSecondsByDay = activeSecondsByDay.filter { key, _ in
            guard let date = date(for: key) else {
                return false
            }

            return date >= cutoff
        }
    }

    private func persist() {
        guard let data = try? encoder.encode(activeSecondsByDay) else {
            return
        }

        userDefaults.set(data, forKey: Keys.activeSecondsByDay)
    }

    private func key(for date: Date) -> String {
        let components = calendar.dateComponents([.year, .month, .day], from: date)
        let year = components.year ?? 0
        let month = components.month ?? 0
        let day = components.day ?? 0
        return String(format: "%04d-%02d-%02d", year, month, day)
    }

    private func date(for key: String) -> Date? {
        let parts = key.split(separator: "-").compactMap { Int($0) }
        guard parts.count == 3 else {
            return nil
        }

        let components = DateComponents(
            calendar: calendar,
            year: parts[0],
            month: parts[1],
            day: parts[2]
        )

        return components.date.map(calendar.startOfDay(for:))
    }
}

private enum Keys {
    static let activeSecondsByDay = "activeSecondsByDay"
}

private extension WorkHistoryStore {
    static func loadHistory(
        from userDefaults: UserDefaults,
        using decoder: JSONDecoder
    ) -> [String: TimeInterval] {
        guard let data = userDefaults.data(forKey: Keys.activeSecondsByDay),
              let history = try? decoder.decode([String: TimeInterval].self, from: data) else {
            return [:]
        }

        return history
    }
}
