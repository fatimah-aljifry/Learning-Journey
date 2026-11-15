//
//  DayCircle.swift
//  Challenge_2
//

import SwiftUI

/// One day number in a circle, colored by how that day was logged.
/// Used by both the week strip (Activity) and the month grid (Calendar).
struct DayCircle: View {
    let date: Date
    let status: DayStatus?
    let isToday: Bool
    var size: CGFloat = 44

    var body: some View {
        Text(date, format: .dateTime.day())
            .font(.system(size: size * 0.45, weight: isToday ? .bold : .medium))
            .foregroundStyle(textColor)
            .frame(width: size, height: size)
            .background(backgroundColor, in: .circle)
            .accessibilityElement()
            .accessibilityLabel(accessibilityText)
    }

    // Today is always solid orange (as in the hi-fi); other days are tinted by how they were logged.
    private var backgroundColor: Color {
        if isToday { return .orange }
        switch status {
        case .learned: return .orange.opacity(0.15)
        case .frozen: return .cyan.opacity(0.15)
        case nil: return .clear
        }
    }

    private var textColor: Color {
        if isToday { return .white }
        switch status {
        case .learned: return .orange
        case .frozen: return .cyan
        case nil: return .white
        }
    }

    private var accessibilityText: String {
        let day = date.formatted(.dateTime.weekday(.wide).month(.wide).day())
        switch status {
        case .learned: return "\(day), learned"
        case .frozen: return "\(day), freezed"
        case nil: return isToday ? "\(day), today" : day
        }
    }
}

#Preview {
    HStack {
        DayCircle(date: .now, status: nil, isToday: false)
        DayCircle(date: .now, status: nil, isToday: true)
        DayCircle(date: .now, status: .learned, isToday: false)
        DayCircle(date: .now, status: .frozen, isToday: false)
    }
    .padding()
    .background(.black)
}
