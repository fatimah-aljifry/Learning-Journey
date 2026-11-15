//
//  ViewModelTests.swift
//  Challenge_2Tests
//
//  Screen text and button rules in the ViewModels, plus the Calendar's months and days.
//

import Foundation
import Testing
@testable import Challenge_2

@MainActor
struct ViewModelTests {
    let start = date(2026, 11, 2, 9)   // Monday 9 AM

    // MARK: - Activity

    @Test func cardTextUsesDayAndDays() {
        let (store, _) = makeStore()
        store.startGoal(topic: "Swift", duration: .week, now: start)
        let viewModel = ActivityViewModel(store: store, calendar: testCalendar, now: start)
        #expect(viewModel.streakText == "0 days")

        viewModel.logLearned(at: start + hours(1))
        #expect(viewModel.streakText == "1 day")

        viewModel.logLearned(at: date(2026, 11, 3, 10))
        #expect(viewModel.streakText == "2 days")
    }

    @Test func freezeFooterUsesTheRealLimit() {
        let (store, _) = makeStore()
        store.startGoal(topic: "Swift", duration: .month, now: start)
        let viewModel = ActivityViewModel(store: store, calendar: testCalendar, now: start)

        viewModel.freezeToday(at: start + hours(1))

        #expect(viewModel.freezeFooter == "1 out of 8 Freezes used")
        #expect(viewModel.logButtonState == .logged)
    }

    @Test func nextRefreshIsMidnightOrStreakDeadline() {
        let (store, _) = makeStore()
        store.startGoal(topic: "Swift", duration: .month, now: start)
        let viewModel = ActivityViewModel(store: store, calendar: testCalendar, now: start)

        viewModel.logLearned(at: date(2026, 11, 2, 10))                  // Mon 10 AM → deadline Tue 6 PM
        #expect(viewModel.nextRefreshDate == date(2026, 11, 3))          // Mon: midnight comes first

        viewModel.refresh(at: date(2026, 11, 3, 9))
        #expect(viewModel.nextRefreshDate == date(2026, 11, 3, 18))      // Tue: the streak deadline comes first
    }

    // MARK: - Onboarding and Learning Goal

    @Test func startLearningNeedsARealTopic() {
        let viewModel = OnboardingViewModel()
        #expect(viewModel.selectedDuration == .week)   // Week is the default
        #expect(!viewModel.canStart)

        viewModel.topic = "   "
        #expect(!viewModel.canStart)

        viewModel.topic = "Swift"
        #expect(viewModel.canStart)
    }

    @Test func learningGoalPageStartsEmptyAndNeedsBothFields() {
        let viewModel = LearningGoalViewModel()
        #expect(viewModel.topic.isEmpty && viewModel.selectedDuration == nil)
        #expect(!viewModel.canSave)

        viewModel.topic = "Design"
        #expect(!viewModel.canSave)

        viewModel.requestSave()
        #expect(!viewModel.showUpdateAlert)            // ✓ disabled → no warning

        viewModel.selectedDuration = .month
        viewModel.requestSave()
        #expect(viewModel.showUpdateAlert)             // warning always shows

        viewModel.cancelUpdate()
        #expect(!viewModel.showUpdateAlert)
        #expect(viewModel.topic == "Design")           // Dismiss keeps what was typed
    }

    // MARK: - Calendar

    @Test func calendarStartsAtRegistrationAndLoadsMore() {
        let (store, _) = makeStore()
        store.startGoal(topic: "Swift", duration: .year, now: date(2026, 1, 15, 9))
        let viewModel = CalendarViewModel(store: store, calendar: testCalendar, now: date(2026, 11, 12))

        #expect(viewModel.months.first == date(2026, 1, 1))
        #expect(viewModel.currentMonth == date(2026, 11, 1))
        #expect(viewModel.months.last == date(2027, 11, 1))

        viewModel.loadMoreMonths()
        #expect(viewModel.months.last == date(2028, 11, 1))
        #expect(viewModel.months.count == 35)
    }

    @Test func monthGridHasRightBlanksAndDays() {
        let (store, _) = makeStore()
        let viewModel = CalendarViewModel(store: store, calendar: testCalendar, now: date(2026, 11, 12))

        let november = viewModel.days(in: date(2026, 11, 1))   // 1 Nov 2026 is a Sunday
        #expect(november.prefix { $0 == nil }.count == 0)
        #expect(november.count == 30)

        let february = viewModel.days(in: date(2028, 2, 1))    // Tuesday, leap year
        #expect(february.prefix { $0 == nil }.count == 2)
        #expect(february.compactMap { $0 }.count == 29)
    }
}
