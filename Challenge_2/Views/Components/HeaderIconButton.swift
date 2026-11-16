//
//  HeaderIconButton.swift
//  Challenge_2
//

import SwiftUI

/// Round glass icon button used in the Activity header (✎ edit goal, 📅 calendar).
/// The title isn't shown, but VoiceOver reads it.
struct HeaderIconButton: View {
    let title: String
    let systemImage: String
    let action: () -> Void

    var body: some View {
        Button(title, systemImage: systemImage, action: action)
            .labelStyle(.iconOnly)
            .font(.system(size: 24, weight: .bold))
            .foregroundStyle(.white)
            .buttonStyle(.glass)
            .buttonBorderShape(.circle)
            .controlSize(.large)
    }
}

#Preview {
    HStack {
        HeaderIconButton(title: "Edit learning goal", systemImage: "pencil.and.outline") {}
        HeaderIconButton(title: "Calendar", systemImage: "calendar") {}
    }
    .padding()
    //.background(.black)
   // .preferredColorScheme(.dark)
}
