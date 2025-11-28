//
//  EditDaysView.swift
//  Routines
//
//  Created by Sam Clemente on 9/16/24.
//

import Foundation
import SwiftUI
import SwiftData

public struct EditDaysView: View {
    @Binding var days: [Weekday]
    var iconColor: Color
    @StateObject private var localeObserver = LocaleObserver()
    
    var daysOfTheWeek: [Weekday] {
        DateUtility.allWeekdays()
    }
    
    public var body: some View {
        HStack {
            ForEach(daysOfTheWeek) { weekday in
                DayToggleButton(iconColor: iconColor, weekday: weekday, isSelected: days.contains(weekday)) {
                    withAnimation {
                        toggleDay(weekday)
                    }
                }
            }
        }
        .onReceive(localeObserver.$firstWeekday) { _ in
            // View will automatically refresh when week start changes
            // The daysOfTheWeek computed property will return the new order
        }
        .onReceive(localeObserver.$localeIdentifier) { _ in
            // View will automatically refresh when locale changes
            // Day names will update via DateUtility.displayName()
        }
        .onAppear {
            // Refresh locale settings when view appears (in case user changed settings)
            localeObserver.refresh()
        }
    }
    
    func toggleDay(_ weekday: Weekday) {
        if let index = days.firstIndex(of: weekday) {
            days.remove(at: index)
            print("Removed \(DateUtility.displayName(for: weekday))")
        } else {
            days.append(weekday)
            print("Added \(DateUtility.displayName(for: weekday))")
        }
    }
}
