//
//  MainView.swift
//  Challenge_2
//

import SwiftUI

/// The pages that can be opened from Activity.
enum Route: Hashable {
    case learningGoal
    case calendar
}

/// Navigation after onboarding: Activity is the root page, and the
/// Learning Goal and Calendar pages are pushed on top of it.
struct MainView: View {
    let store: LearningStore

    /// The pages currently open on top of Activity. Empty = Activity is showing.
    @State private var path: [Route] = []
    /// Created once, so Activity's state and midnight refresh loop survive opening other pages.
    @State private var activityViewModel: ActivityViewModel

    init(store: LearningStore) {
        self.store = store
        _activityViewModel = State(initialValue: ActivityViewModel(store: store))
    }

    var body: some View {
        NavigationStack(path: $path) {
            ActivityView(
                viewModel: activityViewModel,
                onEditGoal: { path.append(.learningGoal) },      // ✎ and "Set a goal"
                onOpenCalendar: { path.append(.calendar) }       // 📅
            )
            // Activity draws its own header, so the system bar is hidden there.
            .toolbar(.hidden, for: .navigationBar)
            .navigationDestination(for: Route.self) { route in
                switch route {
                case .learningGoal:
                    // A fresh page each time, so the fields always start empty.
                    LearningGoalView()
                case .calendar:
                    // A fresh page each time, so it always opens on the current month.
                    CalendarView(viewModel: CalendarViewModel(store: store))
                }
            }
        }
        // White back button (as in the hi-fi). Orange buttons set their own color.
        .tint(.white)
    }
}

#Preview("Goal in progress") {
    let defaults = UserDefaults(suiteName: "preview-main") ?? .standard
    defaults.removePersistentDomain(forName: "preview-main")
    let store = LearningStore(defaults: defaults)
    store.startGoal(topic: "Swift", duration: .week, now: .now.addingTimeInterval(-86_400))
    store.log(.learned, now: .now.addingTimeInterval(-86_000))
    return MainView(store: store)
        .environment(store)
     //   .preferredColorScheme(.dark)
}
