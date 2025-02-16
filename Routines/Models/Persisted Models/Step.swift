//
//  Step.swift
//  Routines
//
//  Created by Sam Clemente on 6/30/24.
//
import Foundation
import SwiftData

    
@Model
class Step: Identifiable {
    var id = UUID()
    var name: String
    var order: Int
    var routine: Routine
    var status = StepCompletionStatus.incomplete
    var days: [String] {
        get {
            guard let data = daysData else { return ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"] }
            return (try? JSONDecoder().decode([String].self, from: data)) ?? []
        }
        set {
            daysData = try? JSONEncoder().encode(newValue)
        }
    }
    @Attribute private var daysData: Data?
    
    init(name: String = "Step", routine: Routine, order: Int) {
        self.name = name
        self.routine = routine
        self.order = order
    }
    
    init(name: String = "Step", routine: Routine, order: Int, days: [String]) {
        self.name = name
        self.routine = routine
        self.order = order
        self.days = days
    }
    
    func isToday() -> Bool {
        let date = Date()
        let formatter = DateFormatter()
        
        formatter.dateFormat = "EEEE"
        formatter.locale = Locale(identifier: "en_US")
        
        let dayOfWeek = formatter.string(from: date)
        // print(dayOfWeek)
        
        return days.contains(dayOfWeek)
    }
}
