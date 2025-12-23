//
//  WatchDayToggleButton.swift
//  RoutinesWatch
//
//  Compact day toggle button for watchOS
//

import SwiftUI

struct WatchDayToggleButton: View {
    var iconColor: Color
    let weekday: Weekday
    let isSelected: Bool
    /// When true, indicates this day is not in the parent routine's schedule.
    /// The button will appear dimmed but remain tappable (tapping will expand the routine).
    var isOutsideParentSchedule: Bool = false
    /// When true, indicates this day is required by a child item (e.g., a step uses this day).
    /// The button cannot be toggled off while this is true.
    var isRequiredByChildren: Bool = false
    let action: () -> Void
    
    private var dayDisplayName: String {
        DateUtility.abbreviatedDisplayName(for: weekday)
    }
    
    private var dayFullName: String {
        DateUtility.displayName(for: weekday)
    }
    
    /// Determines the fill color based on selection state
    private var fillColor: Color {
        if isSelected {
            return iconColor
        }
        return .clear
    }
    
    /// Determines the text color based on selection and parent schedule state
    private var textColor: Color {
        if isSelected {
            return .white
        }
        if isOutsideParentSchedule {
            return .secondary.opacity(0.4)
        }
        return .secondary
    }
    
    /// Determines the circle stroke for days outside parent schedule
    private var strokeColor: Color {
        if isOutsideParentSchedule && !isSelected {
            return .secondary.opacity(0.3)
        }
        return .clear
    }
    
    /// Whether the button can be toggled
    private var canToggle: Bool {
        // Can always toggle on (add day)
        if !isSelected {
            return true
        }
        // Cannot toggle off if required by children
        return !isRequiredByChildren
    }
    
    var body: some View {
        Button(action: {
            if canToggle {
                action()
            }
        }) {
            ZStack {
                Circle()
                    .fill(fillColor)
                    .frame(width: 24, height: 24)
                    .overlay(
                        Circle()
                            .stroke(strokeColor, lineWidth: 1)
                    )
                    .overlay(
                        Text(dayDisplayName)
                            .font(.system(size: 10, weight: .bold))
                            .foregroundStyle(textColor)
                    )
                    .opacity(isOutsideParentSchedule && !isSelected ? 0.6 : 1.0)
                
                // Lock indicator for days required by children
                if isRequiredByChildren && isSelected {
                    Image(systemName: "lock.fill")
                        .font(.system(size: 6, weight: .bold))
                        .foregroundStyle(.white.opacity(0.9))
                        .offset(x: 7, y: 7)
                }
            }
        }
        .buttonStyle(.plain)
        .accessibilityLabel(Text(dayFullName))
        .accessibilityValue(Text(accessibilityValueText))
        .accessibilityHint(Text(accessibilityHintText))
    }
    
    private var accessibilityValueText: String {
        if isSelected {
            if isRequiredByChildren {
                return "Selected, required by steps"
            }
            return "Selected"
        }
        if isOutsideParentSchedule {
            return "Not selected, outside routine schedule"
        }
        return "Not selected"
    }
    
    private var accessibilityHintText: String {
        if isRequiredByChildren && isSelected {
            return "\(dayFullName) is required by one or more steps and cannot be removed."
        }
        if isOutsideParentSchedule && !isSelected {
            return "Toggles selection for \(dayFullName). This will also add \(dayFullName) to the routine's schedule."
        }
        return "Toggles selection for \(dayFullName)"
    }
}
