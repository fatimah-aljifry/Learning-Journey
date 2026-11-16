//
//  CalendarView.swift
//  Challenge_2
//

import SwiftUI

/// "Activities": every month since registration with learned / frozen days. View only.
struct CalendarView: View {
    @State private var viewModel: CalendarViewModel
    /// The month currently scrolled to; set to the current month when the page opens.
    @State private var visibleMonth: Date?

    init(viewModel: CalendarViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        ScrollView {
            // Lazy: only the months on screen are built, so the list can grow forever.
            LazyVStack(alignment: .leading, spacing: 32) {
                ForEach(viewModel.months, id: \.self) { month in
                    MonthGridView(month: month, days: viewModel.days(in: month), today: viewModel.now) { day in
                        viewModel.status(for: day)
                    }
                    .onAppear {
                        // Reached the last loaded month → load the next 12.
                        if month == viewModel.months.last {
                            viewModel.loadMoreMonths()
                        }
                    }
                }
            }
            // Lets the scroll view track each month by its date, so it can jump to one.
            .scrollTargetLayout()
            .padding(.horizontal, 16)
            .padding(.vertical, 16)
        }
        .scrollPosition(id: $visibleMonth, anchor: .top)
        .onAppear {
            visibleMonth = viewModel.currentMonth
        }
        // Fill the whole screen, then paint it black (extends behind the status bar automatically).
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.black)
        .navigationTitle("Activities")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Previews

/// A throwaway store for previews: registered `monthsAgo` months ago, with a mix of learned and frozen days.
@MainActor
private func previewCalendar(_ name: String, registeredMonthsAgo monthsAgo: Int) -> CalendarViewModel {
    let defaults = UserDefaults(suiteName: "preview-calendar-\(name)") ?? .standard
    defaults.removePersistentDomain(forName: "preview-calendar-\(name)")
    let store = LearningStore(defaults: defaults)
    let calendar = Calendar.current
    let today = calendar.startOfDay(for: .now)
    let start = calendar.date(byAdding: .month, value: -monthsAgo, to: today) ?? today
    store.startGoal(topic: "Swift", duration: .year, now: start)

    // Log most days since registration (every 6th day frozen, every 9th skipped), oldest first.
    let dayCount = calendar.dateComponents([.day], from: start, to: today).day ?? 0
    for offset in 0..<dayCount where offset % 9 != 4 {
        let day = calendar.date(byAdding: .hour, value: offset * 24 + 10, to: start) ?? start
        store.log(offset % 6 == 5 ? .frozen : .learned, now: day)
    }
    return CalendarViewModel(store: store)
}

#Preview("Registered 3 months ago") {
    NavigationStack {
        CalendarView(viewModel: previewCalendar("history", registeredMonthsAgo: 3))
    }
   // .preferredColorScheme(.dark)
    .tint(.orange)
}

#Preview("New user") {
    NavigationStack {
        CalendarView(viewModel: previewCalendar("new", registeredMonthsAgo: 0))
    }
   // .preferredColorScheme(.dark)
    .tint(.orange)
}
