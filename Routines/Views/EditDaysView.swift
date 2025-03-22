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
    @Binding var days: [String]
    var iconColor: Color
    
    let daysOfTheWeek = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]
    
    public var body: some View {
        HStack {
            ForEach(daysOfTheWeek, id: \.self) { day in
                DayToggleButton(iconColor: iconColor, day: day, isSelected: days.contains(day)) {
                    withAnimation {
                        toggleDay(day)
                    }
                }
            }
        }
    }
    
    func toggleDay(_ day: String) {
        if let index = days.firstIndex(of: day) {
            days.remove(at: index)
            print("Removed \(day)")
        } else {
            days.append(day)
            print("Added \(day)")
        }
    }
}
