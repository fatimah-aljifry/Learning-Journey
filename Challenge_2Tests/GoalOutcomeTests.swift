//
//  GoalOutcomeTests.swift
//  Challenge_2Tests
//
//  Goal length, "Well done!" and "You didn't reach your goal".
//

import Foundation
import Testing
@testable import Challenge_2

@MainActor
struct GoalOutcomeTests {
    let start = date(2026, 11, 2, 15)   // Monday 3 PM

    @Test func goalLengthsInDays() {
        func days(_ duration: GoalDuration, from startDate: Date) -> Int {
            LearningGoal(topic: "x", duration: duration, startDate: startDate).dayCount(calendar: testCalendar)
        }
        #expect(days(.week, from: start) == 7)
        #expect(days(.month, from: date(2026, 11, 2)) == 30)   // 2 Nov → 1 Dec
        #expect(days(.month, from: date(2028, 2, 1)) == 29)    // leap February
        #expect(days(.year, from: date(2027, 1, 1)) == 365)
        #expect(days(.year, from: date(2028, 1, 1)) == 366)    // leap year
    }

    @Test func goalEndsAtMidnightAfterLastDay() {
        let goal = LearningGoal(topic: "x", duration: .week, startDate: start)
        #expect(goal.endDate(calendar: testCalendar) == date(2026, 11, 9))   // Mon 3 PM start → ends next Mon 12 AM
    }

    @Test func wellDoneShowsRightAfterTheLastLog() {
        let (store, _) = makeStore()
        store.startGoal(topic: "Swift", duration: .week, now: start)
        for day in 2...6 { store.log(.learned, now: date(2026, 11, day, 18)) }   // 5 learned
        store.log(.frozen, now: date(2026, 11, 7, 18))                          // 1 frozen
        #expect(store.outcome(now: date(2026, 11, 7, 19)) == .inProgress)       // 6 of 7

        store.log(.frozen, now: date(2026, 11, 8, 10))                          // 7th day, frozen

        #expect(store.outcome(now: date(2026, 11, 8, 10, 1)) == .completed)     // before the week is over
    }

    @Test func notReachedShowsAtMidnightIfLastDayNotLogged() {
        let (store, _) = makeStore()
        store.startGoal(topic: "Swift", duration: .week, now: start)
        for day in 2...7 { store.log(.learned, now: date(2026, 11, day, 20)) }  // Sunday skipped

        #expect(store.outcome(now: date(2026, 11, 8, 23)) == .inProgress)       // Sunday 11 PM
        #expect(store.outcome(now: date(2026, 11, 9, 0, 1)) == .missed)         // Monday 12:01 AM
    }

    @Test func everyDayLoggedIsWellDoneEvenIfTheStreakBroke() {
        let (store, _) = makeStore()
        store.startGoal(topic: "Swift", duration: .week, now: start)
        store.log(.learned, now: date(2026, 11, 2, 15, 30))                     // Mon 3:30 PM
        store.log(.learned, now: date(2026, 11, 3, 23, 59))                     // Tue 11:59 PM: 32.5 h → streak breaks
        for day in 4...8 { store.log(.learned, now: date(2026, 11, day, 20)) }  // Wed–Sun

        #expect(store.streakCount == 6)                                         // 🔥 reset: Monday was lost
        #expect(store.loggedDaysInGoal == 7)                                    // but every day has a log
        #expect(store.outcome(now: date(2026, 11, 8, 20, 1)) == .completed)     // → Well done
    }

    @Test func logBeforeAGoalUpdateDoesNotCountForTheNewGoal() {
        let (store, _) = makeStore()
        store.startGoal(topic: "Swift", duration: .week, now: start)
        store.log(.learned, now: date(2026, 11, 2, 16))
        store.updateGoal(topic: "Design", duration: .week, now: date(2026, 11, 2, 17))

        #expect(store.loggedDaysInGoal == 0)                                    // must log again for the new goal

        store.log(.learned, now: date(2026, 11, 2, 18))
        #expect(store.loggedDaysInGoal == 1)
    }

    @Test func skippedDayMeansNotReached() {
        let (store, _) = makeStore()
        store.startGoal(topic: "Swift", duration: .week, now: start)
        store.log(.learned, now: date(2026, 11, 2, 20))
        // Tuesday skipped
        for day in 4...8 { store.log(.learned, now: date(2026, 11, day, 10)) }

        #expect(store.outcome(now: date(2026, 11, 9, 0, 1)) == .missed)
    }
}
