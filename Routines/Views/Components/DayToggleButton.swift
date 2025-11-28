//
//  DayToggleButton.swift
//  Routines
//
//  Created by Sam Clemente on 9/16/24.
//

import SwiftUI

struct DayToggleButton: View {
    var iconColor: Color
    let weekday: Weekday
    let isSelected: Bool
    let action: () -> Void
    @StateObject private var localeObserver = LocaleObserver()
    
    private var dayDisplayName: String {
        DateUtility.abbreviatedDisplayName(for: weekday)
    }
    
    private var dayFullName: String {
        DateUtility.displayName(for: weekday)
    }
    
    var body: some View {
        HStack {
            Circle()
                .fill(isSelected ? iconColor : .clear)
                .frame(width: 32)
                .fixedSize()
                .overlay(
                    Text(dayDisplayName)
                        .foregroundStyle(isSelected ? .white : .secondary)
                        .bold()
                )
                .onTapGesture {
                    action()
                }
                .accessibilityElement(children: .ignore)
                .accessibilityLabel(Text(dayFullName))
                .accessibilityValue(Text(isSelected ? "Selected" : "Not selected"))
                .accessibilityAddTraits(.isButton)
                .accessibilityHint(Text("Toggles selection for \(dayFullName)"))
                .accessibilityAction {
                    action()
                }
        }
        .frame(maxWidth: .infinity)
        .onReceive(localeObserver.$localeIdentifier) { _ in
            // View will automatically refresh when locale changes
            // Day names will update via DateUtility.displayName()
        }
        .onReceive(localeObserver.$firstWeekday) { _ in
            // View will automatically refresh when week start changes
        }
        .onAppear {
            // Refresh locale settings when view appears
            localeObserver.refresh()
        }
    }
}
