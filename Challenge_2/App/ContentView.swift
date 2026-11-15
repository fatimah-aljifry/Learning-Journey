import SwiftUI

/// Decides which part of the app to show:
/// - No goal has ever been set → Onboarding (it disappears once a goal is set).
/// - Otherwise → the main flow, opening on Activity (today's status, or the last goal's result).
struct ContentView: View {
    @Environment(LearningStore.self) private var store

    var body: some View {
        Group {
            if store.goal == nil {
                OnboardingView()
                    .transition(.opacity)
            } else {
                MainView(store: store)
                    .transition(.opacity)
            }
        }
        // When "Start Learning" saves the first goal, fade from Onboarding to Activity.
        .animation(.easeInOut(duration: 0.3), value: store.goal == nil)
    }
}

#Preview("First launch") {
    ContentView()
        .environment(LearningStore(defaults: UserDefaults(suiteName: "preview-content") ?? .standard))
        .preferredColorScheme(.dark)
        .tint(.orange)
}
