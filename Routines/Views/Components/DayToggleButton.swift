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
    /// When true, indicates this day is not in the parent routine's schedule.
    /// The button will appear dimmed but remain tappable (tapping will expand the routine).
    var isOutsideParentSchedule: Bool = false
    /// When true, indicates this day is required by a child item (e.g., a step uses this day).
    /// The button cannot be toggled off while this is true.
    var isRequiredByChildren: Bool = false
    /// When true, indicates this is the last day and cannot be removed.
    var requiresAtLeastOneDay: Bool = false
    let action: () -> Bool
    /// Optional callback for long press gesture
    var onLongPress: (() -> Void)? = nil
    @StateObject private var localeObserver = LocaleObserver()
    @State private var shakeOffset: CGFloat = 0
    
    private var dayDisplayName: String {
        DateUtility.abbreviatedDisplayName(for: weekday)
    }
    
    private var dayFullName: String {
        DateUtility.displayName(for: weekday)
    }
    
    /// Determines the fill color based on selection and parent schedule state
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
    
    /// Determines the circle stroke for days outside parent schedule or required by children
    private var strokeColor: Color {
        if isOutsideParentSchedule && !isSelected {
            return .secondary.opacity(0.3)
        }
        return .clear
    }
    
    /// Accessibility hint based on state
    private var accessibilityHintText: String {
        var hint = ""
        if isRequiredByChildren && isSelected {
            hint = "\(dayFullName) is required by one or more steps and cannot be removed."
        } else if isOutsideParentSchedule && !isSelected {
            hint = "Toggles selection for \(dayFullName). This will also add \(dayFullName) to the routine's schedule."
        } else {
            hint = "Toggles selection for \(dayFullName)"
        }
        
        // Add long press hint if callback is provided
        if onLongPress != nil {
            hint += " Long press to add \(dayFullName) to all steps."
        }
        
        return hint
    }
    
    /// Whether the button can be toggled
    private var canToggle: Bool {
        // Can always toggle on (add day)
        if !isSelected {
            return true
        }
        // Cannot toggle off if required by children or if it's the last day
        return !isRequiredByChildren && !requiresAtLeastOneDay
    }
    
    var body: some View {
        HStack {
            ZStack {
                Circle()
                    .fill(fillColor)
                    .frame(width: 32)
                    .fixedSize()
                    .overlay(
                        Circle()
                            .stroke(strokeColor, lineWidth: 1)
                    )
                    .overlay(
                        Text(dayDisplayName)
                            .foregroundStyle(textColor)
                            .bold()
                    )
                    .opacity(isOutsideParentSchedule && !isSelected ? 0.6 : 1.0)
                
                // Lock indicator for days required by children
                if isRequiredByChildren && isSelected {
                    Image(systemName: "lock.fill")
                        .font(.system(size: 8, weight: .bold))
                        .foregroundStyle(.white.opacity(0.9))
                        .offset(x: 10, y: 10)
                }
            }
            .offset(x: shakeOffset)
            .onTapGesture {
                if canToggle {
                    // Provide haptic feedback for successful toggle
                    HapticFeedback.light()
                    let success = action()
                    // If action returns false, it means the toggle was blocked
                    if !success {
                        triggerErrorFeedback()
                    }
                } else {
                    // Provide error haptic feedback and shake animation for blocked action
                    triggerErrorFeedback()
                }
            }
            .onLongPressGesture(minimumDuration: 0.5) {
                // Provide haptic feedback for long press
                HapticFeedback.medium()
                onLongPress?()
            }
                .accessibilityElement(children: .ignore)
                .accessibilityLabel(Text(dayFullName))
                .accessibilityValue(Text(accessibilityValueText))
                .accessibilityAddTraits(.isButton)
                .accessibilityHint(Text(accessibilityHintText))
                .accessibilityAction {
                    if canToggle {
                        let success = action()
                        if !success {
                            triggerErrorFeedback()
                        }
                    } else {
                        triggerErrorFeedback()
                    }
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
    
    /// Triggers error haptic feedback and shake animation
    private func triggerErrorFeedback() {
        HapticFeedback.error()
        withAnimation(.easeInOut(duration: 0.1).repeatCount(3, autoreverses: true)) {
            shakeOffset = -8
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            withAnimation {
                shakeOffset = 0
            }
        }
    }
}
