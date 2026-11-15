//
//  CalendarViewModel.swift
//  Challenge_2
//

import Foundation
import Observation

/// Supplies the Calendar page with its months and day cells.
/// The list starts at the registration month and grows 12 months at a time as the user scrolls down.
@MainActor
@Observable
final class CalendarViewModel {
    /// How many months are added each time the user reaches the end of the list.
    static let monthsPerPage = 12

    /// The months loaded so far (each one is the 1st of that month), oldest first.
    private(set) var months: [Date] = []

    /// Today, for the solid orange highlight.
    let now: Date

    @ObservationIgnored private let store: LearningStore
    @ObservationIgnored private let calendar: Calendar

    /// `now` is only passed by tests; the app uses `AppClock.shared.now`.
    init(store: LearningStore, calendar: Calendar = .current, now: Date? = nil) {
        self.store = store
        self.calendar = calendar
        self.now = now ?? AppClock.shared.now

        // Start at the registration month and load up to 12 months past the current one.
        var month = firstMonth
        let end = calendar.date(byAdding: .month, value: Self.monthsPerPage, to: currentMonth) ?? currentMonth
        while month <= end {
            months.append(month)
            month = nextMonth(after: month)
        }
    }

    // MARK: - Months

    /// The 1st of the registration month: the top of the list (can't scroll above it).
    var firstMonth: Date {
        startOfMonth(store.registrationDate ?? now)
    }

    /// The 1st of this month: where the page opens.
    var currentMonth: Date {
        startOfMonth(now)
    }

    /// Adds the next 12 months to the end of the list. Called when the last month appears on screen.
    func loadMoreMonths() {
        guard var month = months.last else { return }
        for _ in 0..<Self.monthsPerPage {
            month = nextMonth(after: month)
            months.append(month)
        }
    }

    // MARK: - Days

    /// The grid cells for one month: `nil` blanks before the 1st (so it lands on the right weekday), then each day.
    func days(in month: Date) -> [Date?] {
        let dayCount = calendar.range(of: .day, in: .month, for: month)?.count ?? 30
        let weekdayOfFirst = calendar.component(.weekday, from: month)
        let leadingBlanks = (weekdayOfFirst - calendar.firstWeekday + 7) % 7
        let blanks: [Date?] = Array(repeating: nil, count: leadingBlanks)
        let days: [Date?] = (0..<dayCount).map { calendar.date(byAdding: .day, value: $0, to: month) }
        return blanks + days
    }

    /// How a day is colored (the most recent log of that day).
    func status(for date: Date) -> DayStatus? {
        store.status(for: date)
    }

    // MARK: - Helpers

    private func startOfMonth(_ date: Date) -> Date {
        calendar.dateInterval(of: .month, for: date)?.start ?? calendar.startOfDay(for: date)
    }

    private func nextMonth(after month: Date) -> Date {
        calendar.date(byAdding: .month, value: 1, to: month) ?? month.addingTimeInterval(31 * 86_400)
    }
}
