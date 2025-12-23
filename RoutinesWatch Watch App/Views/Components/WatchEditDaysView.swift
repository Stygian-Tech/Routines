//
//  WatchEditDaysView.swift
//  RoutinesWatch
//
//  Compact day picker for watchOS
//

import SwiftUI

struct WatchEditDaysView: View {
    @Binding var days: [Weekday]
    var iconColor: Color
    /// When provided, days not in this array will appear dimmed.
    /// Used when editing step days to show which days are outside the parent routine's schedule.
    var parentRoutineDays: [Weekday]? = nil
    /// Days that are required by children (e.g., steps) and cannot be removed.
    /// Used when editing routine days to prevent removing days that steps still use.
    var daysRequiredByChildren: Set<Weekday> = []
    /// When true, at least one day must remain selected. Prevents removing the last day.
    var requiresAtLeastOneDay: Bool = false
    
    var daysOfTheWeek: [Weekday] {
        DateUtility.allWeekdays()
    }
    
    var body: some View {
        // Use a grid layout for better fit on watch
        LazyVGrid(columns: [
            GridItem(.flexible()),
            GridItem(.flexible()),
            GridItem(.flexible()),
            GridItem(.flexible())
        ], spacing: 6) {
            ForEach(daysOfTheWeek) { weekday in
                WatchDayToggleButton(
                    iconColor: iconColor,
                    weekday: weekday,
                    isSelected: days.contains(weekday),
                    isOutsideParentSchedule: isOutsideParentSchedule(weekday),
                    isRequiredByChildren: daysRequiredByChildren.contains(weekday)
                ) {
                    withAnimation {
                        toggleDay(weekday)
                    }
                }
            }
        }
    }
    
    /// Checks if a weekday is outside the parent routine's schedule
    private func isOutsideParentSchedule(_ weekday: Weekday) -> Bool {
        guard let parentDays = parentRoutineDays else {
            return false
        }
        return !parentDays.contains(weekday)
    }
    
    private func toggleDay(_ weekday: Weekday) {
        // Prevent removing days required by children
        if days.contains(weekday) && daysRequiredByChildren.contains(weekday) {
            return
        }
        
        if let index = days.firstIndex(of: weekday) {
            // Prevent removing the last day if requiresAtLeastOneDay is true
            if requiresAtLeastOneDay && days.count <= 1 {
                return
            }
            days.remove(at: index)
        } else {
            days.append(weekday)
        }
    }
}
