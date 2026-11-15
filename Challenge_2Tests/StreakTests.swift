//
//  StreakTests.swift
//  Challenge_2Tests
//
//  The 32-hour rule and how freezes affect the streak.
//

import Foundation
import Testing
@testable import Challenge_2

@MainActor
struct StreakTests {
    let start = date(2026, 11, 2, 9)   // Monday 9 AM

    @Test func streakStillAliveAfter31Hours() {
        let (store, _) = makeStore()
        store.startGoal(topic: "Swift", duration: .week, now: start)
        store.log(.learned, now: start)

        store.checkStreak(now: start + hours(31))

        #expect(store.streakCount == 1)
    }

    @Test func streakBreaksAfter33Hours() {
        let (store, _) = makeStore()
        store.startGoal(topic: "Swift", duration: .week, now: start)
        store.log(.learned, now: start)

        store.checkStreak(now: start + hours(33))

        #expect(store.streakCount == 0)
    }

    @Test func freezeKeepsStreakAliveButDoesNotAddToIt() {
        let (store, _) = makeStore()
        store.startGoal(topic: "Swift", duration: .week, now: start)
        store.log(.learned, now: start)                    // Mon
        store.log(.frozen, now: start + hours(24))         // Tue

        store.checkStreak(now: start + hours(24 + 31))     // 31 h after the freeze

        #expect(store.streakCount == 1)                    // still 1: the freeze didn't add
        #expect(store.freezesUsed == 1)
    }

    @Test func lateLogStartsANewStreak() {
        let (store, _) = makeStore()
        store.startGoal(topic: "Swift", duration: .week, now: start)
        store.log(.learned, now: start)                    // Mon 9 AM

        store.log(.learned, now: date(2026, 11, 4, 20))    // Wed 8 PM: 59 h later

        #expect(store.streakCount == 1)                    // the old streak broke; this is a new one
    }

    @Test func streakDeadlineIs32HoursAfterLastLog() {
        let (store, _) = makeStore()
        store.startGoal(topic: "Swift", duration: .week, now: start)
        store.log(.learned, now: start + hours(1))

        #expect(store.streakDeadline == start + hours(1 + 32))
    }
}
