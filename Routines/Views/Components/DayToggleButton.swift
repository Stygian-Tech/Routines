//
//  DayToggleButton.swift
//  Routines
//
//  Created by Sam Clemente on 9/16/24.
//

import SwiftUI

struct DayToggleButton: View {
    var iconColor: Color
    let day: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        HStack {
            Circle()
                .fill(isSelected ? iconColor : .clear)
                .frame(width: 32)
                .fixedSize()
                .overlay(
                    Text(day.prefix(1))
                        .foregroundStyle(isSelected ? .white : .secondary)
                        .bold()
                )
                .onTapGesture {
                    action()
                }
                .accessibilityElement(children: .ignore)
                .accessibilityLabel(Text(day))
                .accessibilityValue(Text(isSelected ? "Selected" : "Not selected"))
                .accessibilityAddTraits(.isButton)
                .accessibilityHint(Text("Toggles selection for \(day)"))
                .accessibilityAction {
                    action()
                }
        }
        .frame(maxWidth: .infinity)
    }
}
