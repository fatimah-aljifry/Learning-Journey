//
//  GoalUpdateTests.swift
//  Challenge_2Tests
//
//  What happens when the user updates their goal (✎ → ✓ → Update).
//

import Foundation
import Testing
@testable import Challenge_2

@MainActor
struct GoalUpdateTests {
    let start = date(2026, 11, 2, 9)        // Monday 9 AM
    let today = date(2026, 11, 3)           // Tuesday

    @Test func updateResetsStreakAndFreezes() {
        let (store, _) = makeStore()
        store.startGoal(topic: "Swift", duration: .week, now: start)
        store.log(.learned, now: date(2026, 11, 2, 10))
        store.log(.frozen, now: date(2026, 11, 3, 10))

        store.updateGoal(topic: "Design", duration: .month, now: date(2026, 11, 3, 14))

        #expect(store.goal?.topic == "Design")
        #expect(store.streakCount == 0)
        #expect(store.freezesUsed == 0)
        #expect(store.freezesRemaining == 8)
    }

    @Test func todaysLearnedLogIsKept() {
        let (store, _) = makeStore()
        store.startGoal(topic: "Swift", duration: .week, now: start)
        store.log(.learned, now: date(2026, 11, 3, 10))

        store.updateGoal(topic: "Design", duration: .week, now: date(2026, 11, 3, 14))

        #expect(store.status(for: today) == .learned)
        #expect(store.todayStatus(now: date(2026, 11, 3, 15)) == nil)   // buttons back on
    }

    @Test func todaysFreezeIsRemoved() {
        let (store, _) = makeStore()
        store.startGoal(topic: "Swift", duration: .week, now: start)
        store.log(.frozen, now: date(2026, 11, 3, 10))

        store.updateGoal(topic: "Design", duration: .week, now: date(2026, 11, 3, 14))

        #expect(store.status(for: today) == nil)
    }

    @Test func mostRecentLogShowsAfterLoggingAgain() {
        let (store, _) = makeStore()
        store.startGoal(topic: "Swift", duration: .week, now: start)
        store.log(.learned, now: date(2026, 11, 3, 10))
        store.updateGoal(topic: "Design", duration: .week, now: date(2026, 11, 3, 14))

        store.log(.frozen, now: date(2026, 11, 3, 17))

        #expect(store.status(for: today) == .frozen)   // the new freeze replaces the old learned
        #expect(store.freezesUsed == 1)
        #expect(store.streakCount == 0)
    }

    @Test func earlierDaysAndRegistrationDateNeverChange() {
        let (store, _) = makeStore()
        store.startGoal(topic: "Swift", duration: .week, now: start)
        store.log(.frozen, now: date(2026, 11, 2, 10))   // Monday freeze

        store.updateGoal(topic: "Design", duration: .week, now: date(2026, 11, 3, 14))

        #expect(store.status(for: date(2026, 11, 2)) == .frozen)
        #expect(store.registrationDate == start)
    }
}
