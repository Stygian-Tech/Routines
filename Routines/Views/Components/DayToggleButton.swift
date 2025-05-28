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
        }
        .frame(maxWidth: .infinity)
    }
}
