//
//  StatCard.swift
//  Challenge_2
//

import SwiftUI

/// A dark glass card showing one count, stacked and centered as in the hi-fi:
/// icon on top, then "3 days", then "Learned".
struct StatCard: View {
    let systemImage: String
    /// Color of the icon only (orange flame / blue snowflake).
    let tint: Color
    /// Already formatted by the ViewModel, e.g. "1 day" or "3 days".
    let value: String
    let label: String

    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: systemImage)
                .font(.title2)
                .foregroundStyle(tint)
                .accessibilityHidden(true)
                .padding(.bottom, 4)

            Text(value)
                .font(.title3.weight(.semibold))
                .foregroundStyle(.white)

            Text(label)
                .font(.footnote)
                .foregroundStyle(.white.opacity(0.8))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        // Clear glass reads as a dark card with a soft edge on the black screen.
        .glassEffect(.clear, in: .rect(cornerRadius: 28))
        .accessibilityElement(children: .combine)
    }
}

#Preview {
    HStack(spacing: 12) {
        StatCard(systemImage: "flame.fill", tint: .orange, value: "3 days", label: "Learned")
        StatCard(systemImage: "snowflake", tint: .cyan, value: "1 day", label: "Freezed")
    }
    .padding()
  //  .background(.black)
  //  .preferredColorScheme(.dark)
}
