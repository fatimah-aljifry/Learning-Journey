//
//  TimeTravelPanel.swift
//  Challenge_2
//
//  DEBUG: time travel — a hidden testing tool. Long-press the "Activity" title to open it.
//  Everything inside `#if DEBUG` is removed from App Store / TestFlight builds automatically.
//  To remove the feature: delete this file and the `.timeTravelOnLongPress()` line in ActivityView.
//

import SwiftUI

extension View {
    /// Long-pressing this view opens the time-travel panel (Debug builds only).
    func timeTravelOnLongPress() -> some View {
        #if DEBUG
        modifier(TimeTravelLongPress())
        #else
        self
        #endif
    }
}

#if DEBUG
private struct TimeTravelLongPress: ViewModifier {
    @State private var isShowingPanel = false

    func body(content: Content) -> some View {
        content
            .onLongPressGesture(minimumDuration: 0.5) { isShowingPanel = true }
            .sheet(isPresented: $isShowingPanel) {
                TimeTravelPanel()
                    .presentationDetents([.medium, .large])
            }
    }
}

/// Buttons to move the app's clock forward, back to real time, or erase all data.
struct TimeTravelPanel: View {
    @Environment(LearningStore.self) private var store
    @Environment(\.dismiss) private var dismiss
    private let clock = AppClock.shared

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Time Travel (Debug)")
                .font(.title3.bold())

            VStack(alignment: .leading, spacing: 4) {
                Text("App time: \(clock.now.formatted(.dateTime.weekday(.abbreviated).day().month(.abbreviated).hour().minute()))")
                Text("Offset: \(offsetText)")
                    .foregroundStyle(.secondary)
            }
            .font(.subheadline.monospacedDigit())

            HStack {
                Button("+1 hour") { clock.travel(by: 3_600) }
                Button("+1 day") { clock.travel(by: 86_400) }
                Button("+33 hours") { clock.travel(by: 33 * 3_600) }
            }
            .buttonStyle(.bordered)

            Button("Next midnight") { clock.travelToNextMidnight() }
                .buttonStyle(.bordered)

            Divider()

            Button("Back to real time") { clock.reset() }
                .buttonStyle(.bordered)

            Button("Erase all data → Onboarding", role: .destructive) {
                clock.reset()
                store.eraseAllData()
                dismiss()
            }
            .buttonStyle(.bordered)

            Spacer()
        }
        .padding(24)
        .frame(maxWidth: .infinity, alignment: .leading)
        .tint(.orange)
    }

    /// e.g. "+1 d 9 h" or "real time".
    private var offsetText: String {
        let totalHours = Int(clock.offset / 3_600)
        guard totalHours != 0 else { return "real time" }
        let days = totalHours / 24
        let hours = totalHours % 24
        let sign = totalHours > 0 ? "+" : "−"
        return days == 0 ? "\(sign)\(abs(hours)) h" : "\(sign)\(abs(days)) d \(abs(hours)) h"
    }
}

#Preview {
    TimeTravelPanel()
        .environment(LearningStore(defaults: UserDefaults(suiteName: "preview-timetravel") ?? .standard))
       // .preferredColorScheme(.dark)
}
#endif
