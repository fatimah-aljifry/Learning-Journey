//
//  AppClock.swift
//  Challenge_2
//

import Foundation
import Observation

/// The app's single source of "now".
///
/// In the App Store build this is always the real time.
/// In Debug builds the time-travel panel can push it forward (`offset`) to test
/// the 32-hour rule, midnight, and goal endings without waiting.
/// DEBUG: time travel
@MainActor
@Observable
final class AppClock {
    static let shared = AppClock()

    /// How far the app's time is ahead of the real time, in seconds. Always 0 outside Debug builds.
    private(set) var offset: TimeInterval = 0

    /// The app's current time: real time + offset.
    var now: Date { Date.now.addingTimeInterval(offset) }

    #if DEBUG
    private static let offsetKey = "debugTimeOffset"

    private init() {
        // Remembered across relaunches, so "reopening the app the next day" can be tested.
        offset = UserDefaults.standard.double(forKey: Self.offsetKey)
    }

    /// Moves the app's time forward (or back with a negative value).
    func travel(by seconds: TimeInterval) {
        setOffset(offset + seconds)
    }

    /// Jumps to one second after the next midnight in app time.
    func travelToNextMidnight(calendar: Calendar = .current) {
        let startOfToday = calendar.startOfDay(for: now)
        guard let midnight = calendar.date(byAdding: .day, value: 1, to: startOfToday) else { return }
        travel(by: midnight.timeIntervalSince(now) + 1)
    }

    /// Back to the real time.
    func reset() {
        setOffset(0)
    }

    private func setOffset(_ value: TimeInterval) {
        offset = value
        UserDefaults.standard.set(value, forKey: Self.offsetKey)
    }
    #else
    private init() {}
    #endif
}
