//
//  LoggingTests.swift
//  Challenge_2Tests
//
//  One log per day per goal, midnight reset, and freeze limits.
//

import Foundation
import Testing
@testable import Challenge_2

@MainActor
struct LoggingTests {
    let start = date(2026, 11, 2, 9)   // Monday 9 AM

    @Test func secondLogOnSameDayIsIgnored() {
        let (store, _) = makeStore()
        store.startGoal(topic: "Swift", duration: .week, now: start)

        store.log(.learned, now: start + hours(1))
        store.log(.learned, now: start + hours(2))

        #expect(store.data.logs.count == 1)
        #expect(store.streakCount == 1)
    }

    @Test func buttonsComeBackAtMidnightEvenAfter11PMLog() {
        let (store, _) = makeStore()
        store.startGoal(topic: "Swift", duration: .week, now: start)
        store.log(.learned, now: date(2026, 11, 2, 23))

        #expect(store.todayStatus(now: date(2026, 11, 2, 23, 30)) == .learned)   // still Monday: off
        #expect(store.todayStatus(now: date(2026, 11, 3, 0, 0)) == nil)          // Tuesday 12 AM: on
    }

    @Test func freezeIsBlockedAfterLoggingLearned() {
        let (store, _) = makeStore()
        store.startGoal(topic: "Swift", duration: .week, now: start)
        store.log(.learned, now: start + hours(1))

        store.log(.frozen, now: start + hours(2))

        #expect(store.freezesUsed == 0)
        #expect(store.status(for: start) == .learned)
    }

    @Test func weekGoalAllowsOnlyTwoFreezes() {
        let (store, _) = makeStore()
        store.startGoal(topic: "Swift", duration: .week, now: start)

        store.log(.frozen, now: date(2026, 11, 2, 10))
        store.log(.frozen, now: date(2026, 11, 3, 10))
        store.log(.frozen, now: date(2026, 11, 4, 10))   // 3rd: blocked

        #expect(store.freezesUsed == 2)
        #expect(store.freezesRemaining == 0)
        #expect(store.status(for: date(2026, 11, 4)) == nil)
    }

    @Test(arguments: [(GoalDuration.week, 2), (.month, 8), (.year, 96)])
    func freezeLimits(duration: GoalDuration, limit: Int) {
        #expect(duration.freezeLimit == limit)
    }

    @Test func cannotLogAfterGoalHasEnded() {
        let (store, _) = makeStore()
        store.startGoal(topic: "Swift", duration: .week, now: start)

        store.log(.learned, now: date(2026, 11, 10, 9))   // the week ended at 12 AM on 9 Nov

        #expect(store.data.logs.isEmpty)
    }

    @Test func dataSurvivesReopeningTheApp() {
        let (store, defaults) = makeStore()
        store.startGoal(topic: "Swift", duration: .month, now: start)
        store.log(.learned, now: start + hours(1))

        let reopened = LearningStore(defaults: defaults, calendar: testCalendar)

        #expect(reopened.goal?.topic == "Swift")
        #expect(reopened.goal?.duration == .month)
        #expect(reopened.data.logs.count == 1)
        #expect(reopened.registrationDate == start)
    }
}
