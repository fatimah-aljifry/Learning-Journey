//
//  LearningGoalViewModel.swift
//  Challenge_2
//

import Foundation
import Observation

/// Holds what the user enters on the Learning Goal page and saves the new goal
/// after they confirm the "Update goal" warning.
@MainActor
@Observable
final class LearningGoalViewModel {
    /// Starts empty every time the page opens.
    var topic = ""
    /// Starts with nothing picked.
    var selectedDuration: GoalDuration?
    /// `true` shows the "Update goal" alert.
    var showUpdateAlert = false

    /// ✓ is only enabled when a topic (not just spaces) and a duration are both set.
    var canSave: Bool {
        !topic.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && selectedDuration != nil
    }

    /// ✓ tapped → always show the warning first (even if the previous goal already ended).
    func requestSave() {
        guard canSave else { return }
        showUpdateAlert = true
    }

    /// "Dismiss" tapped → close the warning and stay on the page, keeping what was typed.
    func cancelUpdate() {
        showUpdateAlert = false
    }

    /// "Update" tapped in the alert → save the new goal.
    /// The store resets the streak and freezes, keeps today's learned log and removes today's freeze.
    func confirmUpdate(in store: LearningStore) {
        guard canSave, let selectedDuration else { return }
        store.updateGoal(topic: topic, duration: selectedDuration)
    }
}
