//
//  LearningGoalView.swift
//  Challenge_2
//

import SwiftUI

/// Lets the user change their learning goal. Opened from the ✎ button or "Set a goal" on Activity.
struct LearningGoalView: View {
    @Environment(LearningStore.self) private var store
    @Environment(\.dismiss) private var dismiss
    /// Created fresh each time the page opens, so the fields always start empty.
    @State private var viewModel: LearningGoalViewModel

    /// `viewModel` is only passed in by previews; the app uses a fresh, empty one.
    init(viewModel: LearningGoalViewModel? = nil) {
        _viewModel = State(initialValue: viewModel ?? LearningGoalViewModel())
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("I want to learn")
                .foregroundStyle(.white)

            GoalTextField(text: $viewModel.topic)
                .padding(.bottom, 24)

            Text("I want to learn it in a")
                .foregroundStyle(.white)
                .padding(.bottom, 10)

            DurationPicker(selection: $viewModel.selectedDuration)

            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.top, 24)
        // Fill the whole screen, then paint it black (extends behind the status bar automatically).
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.black)
        .navigationTitle("Learning Goal")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                // `.confirm` role: shown as a prominent (orange) glass button, gray when disabled.
                Button("Save", systemImage: "checkmark", role: .confirm) {
                    viewModel.requestSave()
                }
                // Also off while the warning is showing, so it can't be tapped twice.
                .disabled(!viewModel.canSave || viewModel.showUpdateAlert)
            }
        }
        // Custom warning (matches the hi-fi) shown on top of the page.
        .overlay {
            if viewModel.showUpdateAlert {
                UpdateGoalAlert(
                    onDismiss: viewModel.cancelUpdate,
                    onUpdate: {
                        viewModel.confirmUpdate(in: store)
                        dismiss()
                    }
                )
                .transition(.opacity.combined(with: .scale(scale: 1.1)))
            }
        }
        .animation(.easeOut(duration: 0.2), value: viewModel.showUpdateAlert)
    }
}

#Preview("Empty") {
    NavigationStack {
        LearningGoalView()
    }
    .environment(LearningStore(defaults: UserDefaults(suiteName: "preview") ?? .standard))
    .preferredColorScheme(.dark)
    .tint(.orange)
}

#Preview("Filled in") {
    let viewModel = LearningGoalViewModel()
    viewModel.topic = "Design"
    viewModel.selectedDuration = .month
    return NavigationStack {
        LearningGoalView(viewModel: viewModel)
    }
    .environment(LearningStore(defaults: UserDefaults(suiteName: "preview") ?? .standard))
    .preferredColorScheme(.dark)
    .tint(.orange)
}

#Preview("Update alert") {
    let viewModel = LearningGoalViewModel()
    viewModel.topic = "Design"
    viewModel.selectedDuration = .month
    viewModel.showUpdateAlert = true
    return NavigationStack {
        LearningGoalView(viewModel: viewModel)
    }
    .environment(LearningStore(defaults: UserDefaults(suiteName: "preview") ?? .standard))
    .preferredColorScheme(.dark)
    .tint(.orange)
}
