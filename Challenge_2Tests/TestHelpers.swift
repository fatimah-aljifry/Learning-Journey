//
//  TestHelpers.swift
//  Challenge_2Tests
//
//  Shared helpers so every test uses fixed dates and its own empty storage.
//

import Foundation
@testable import Challenge_2

/// A fixed calendar (Sunday-first, fixed time zone) so tests give the same result on any Mac, any day.
let testCalendar: Calendar = {
    var calendar = Calendar(identifier: .gregorian)
    calendar.timeZone = TimeZone(identifier: "Asia/Riyadh") ?? .gmt
    calendar.firstWeekday = 1
    return calendar
}()

/// A pretend moment, e.g. `date(2026, 11, 2, 9)` = Monday 2 Nov 2026, 9:00 AM.
func date(_ year: Int, _ month: Int, _ day: Int, _ hour: Int = 0, _ minute: Int = 0) -> Date {
    testCalendar.date(from: DateComponents(year: year, month: month, day: day, hour: hour, minute: minute)) ?? .distantPast
}

/// A store with its own empty storage, so tests never touch real app data or each other.
@MainActor
func makeStore() -> (store: LearningStore, defaults: UserDefaults) {
    let suite = "test-\(UUID().uuidString)"
    let defaults = UserDefaults(suiteName: suite) ?? .standard
    return (LearningStore(defaults: defaults, calendar: testCalendar), defaults)
}

/// Shorthand for an hour count in seconds.
func hours(_ value: Double) -> TimeInterval { value * 3600 }
