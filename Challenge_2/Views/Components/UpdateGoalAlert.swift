//
//  UpdateGoalAlert.swift
//  Challenge_2
//

import SwiftUI

/// The custom "Update goal" warning from the hi-fi: dark card, gray Dismiss, filled orange Update.
/// Shown on top of the Learning Goal page with a dimmed background.
struct UpdateGoalAlert: View {
    let onDismiss: () -> Void
    let onUpdate: () -> Void

    var body: some View {
        ZStack {
            // Dims the page behind the card. Tapping it does nothing, like a system alert.
            Color.black.opacity(0.5)
                .ignoresSafeArea()
                .accessibilityHidden(true)

            card
        }
    }

    private var card: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Update goal")
                .font(.headline)
                .foregroundStyle(.white)

            Text("If you update now, your streak will start over.")
                .font(.subheadline)
                .foregroundStyle(.gray)

            HStack(spacing: 10) {
                Button("Dismiss", action: onDismiss)
                    .buttonStyle(AlertButtonStyle(fill: Color(white: 0.2)))

                Button("Update", action: onUpdate)
                    .buttonStyle(AlertButtonStyle(fill: .orange))
            }
            .padding(.top, 16)
        }
        .padding(20)
        .frame(maxWidth: 320)
        .background {
            RoundedRectangle(cornerRadius: 32)
                .fill(Color(white: 0.11))
                .stroke(Color.white.opacity(0.08), lineWidth: 1)
        }
        .shadow(color: .black.opacity(0.4), radius: 20)
        // VoiceOver treats the card like a system alert: focus stays inside it.
        .accessibilityElement(children: .contain)
        .accessibilityAddTraits(.isModal)
    }
}

/// Capsule button used inside the alert: solid fill, white bold text, dims while pressed.
private struct AlertButtonStyle: ButtonStyle {
    let fill: Color

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity, minHeight: 48)
            .background(fill, in: Capsule())
            .opacity(configuration.isPressed ? 0.7 : 1)
    }
}

#Preview {
    UpdateGoalAlert(onDismiss: {}, onUpdate: {})
      //  .background(.black)
       // .preferredColorScheme(.dark)
}
